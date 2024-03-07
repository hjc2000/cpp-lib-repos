$build_script_path = Split-Path -Path $MyInvocation.MyCommand.Definition -Parent
. $build_script_path/../.base-script/prepare-for-building.ps1

$source_path = "$repos_path/cairo/"
$install_path = "$libs_path/cairo/"
$build_path = "$source_path/build/"
Push-Location $repos_path
try
{
	Apt-Ensure-Packets @("docbook-utils", "docbook", "docbook-to-man", "docbook-xml")

	# 构建依赖项
	& "${build_script_path}/build-zlib.ps1"
	& "${build_script_path}/build-libexpat.ps1"
	& "${build_script_path}/build-glib.ps1"
	& "${build_script_path}/build-libpng.ps1"
	& "${build_script_path}/build-freetype.ps1"
	& "${build_script_path}/build-libiconv.ps1"



	# 开始构建本体
	Set-Location $repos_path
	get-git-repo.ps1 -git_url "https://gitlab.freedesktop.org/cairo/cairo.git"

	New-Item -Path $build_path -ItemType Directory -Force | Out-Null
	Remove-Item "$build_path/*" -Recurse -Force

	Create-Text-File -Path $build_path/cross_file.ini `
		-Content @"
	[binaries]
	c = 'arm-none-linux-gnueabihf-gcc'
	cpp = 'arm-none-linux-gnueabihf-g++'
	ar = 'arm-none-linux-gnueabihf-ar'
	ld = 'arm-none-linux-gnueabihf-ld'
	strip = 'arm-none-linux-gnueabihf-strip'
	pkg-config = 'pkg-config'

	[host_machine]
	system = 'linux'
	cpu_family = 'arm'
	cpu = 'armv4'
	endian = 'little'

	[target_machine]
	system = 'linux'
	cpu_family = 'arm'
	cpu = 'armv4'
	endian = 'little'

	# 如果不设置低于 avmv6 的版本，编译时就会报内联汇编有不可能的约束。
	[built-in options]
	c_args = ['-march=armv4', '-I$total_install_path/include']
	cpp_args = ['-march=armv4', '-I$total_install_path/include']
	c_link_args = ['-L$total_install_path/lib/', '$total_install_path/lib/libiconv.so.2', '$total_install_path/lib/libz.so.1']
	cpp_link_args = ['-L$total_install_path/lib/']
"@

	Set-Location $source_path
	meson setup build/ `
		--prefix="$install_path" `
		--cross-file="$build_path/cross_file.ini" `
		-Dtests=disabled `
		-Dxlib=disabled
	if ($LASTEXITCODE)
	{
		throw "配置失败"
	}
	
	Set-Location $build_path
	ninja -j12 | Out-Null
	if ($LASTEXITCODE)
	{
		throw "编译失败"
	}

	ninja install | Out-Null

	Install-Lib -src_path $install_path -dst_path $total_install_path
}
catch
{
	throw
}
finally
{
	Pop-Location
}
