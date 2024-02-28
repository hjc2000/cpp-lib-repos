$build_script_path = Split-Path -Path $MyInvocation.MyCommand.Definition -Parent
. $build_script_path/../base-script/prepare-for-building.ps1

$source_path = "$repos_path/FFmpeg/"
$install_path = "$libs_path/ffmpeg/"
Push-Location $repos_path
try
{
	# 编译依赖项
	& $build_script_path/build-x264.ps1
	& $build_script_path/build-x265.ps1
	& $build_script_path/build-sdl2.ps1
	& $build_script_path/build-amf.ps1
	& $build_script_path/build-openssl.ps1

	$env:PKG_CONFIG_PATH = 
	"$(cygpath.exe ${libs_path})/x264/lib/pkgconfig:" +
	"$(cygpath.exe $libs_path)/x265/lib/pkgconfig:" +
	"$(cygpath.exe $libs_path)/openssl/lib64/pkgconfig:" +
	"$(cygpath.exe $libs_path)/SDL2/lib/pkgconfig:"
	Write-Host $env:PKG_CONFIG_PATH

	Set-Location $repos_path
	get-git-repo.ps1 -git_url "https://gitee.com/programmingwindows/FFmpeg.git" `
		-branch_name release/6.1

	run-bash-cmd.ps1 @"
set -e
cd $(cygpath.exe $source_path)

./configure \
--prefix="$(cygpath.exe $install_path)" \
--extra-cflags="-I$(cygpath.exe $libs_path)/amf/include/ -DAMF_CORE_STATICTIC" \
--enable-libx264 \
--enable-libx265 \
--enable-openssl \
--enable-version3 \
--enable-amf \
--enable-pic \
--enable-gpl \
--enable-shared \
--disable-static

make clean
make -j12
make install
"@



	# 将 msys2 中的 dll 复制到安装目录
	# 可以用 ldd ffmpeg.exe | grep ucrt64 命令来查看有哪些依赖是来自 ucrt64 的
	$msys_dlls = @(
		"/ucrt64/bin/libgcc_s_seh-1.dll",
		"/ucrt64/bin/libbz2-1.dll",
		"/ucrt64/bin/libiconv-2.dll",
		"/ucrt64/bin/liblzma-5.dll",
		"/ucrt64/bin/libstdc++-6.dll",
		"/ucrt64/bin/libwinpthread-1.dll",
		"/ucrt64/bin/zlib1.dll"
	)
	Write-Host "正在复制 msys2 中的 dll 到 安装目录/bin"
	foreach ($msys_dll in $msys_dlls)
	{
		Copy-Item -Path $(cygpath.exe $msys_dll -w) `
			-Destination "$install_path/bin/" `
			-Force
	}
}
catch
{
	<#Do this if a terminating exception happens#>
}
finally
{
	Pop-Location
}