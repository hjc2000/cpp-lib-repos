$build_script_path = Split-Path -Path $MyInvocation.MyCommand.Definition -Parent
. $build_script_path/../.base-script/prepare-for-building.ps1

$source_path = "$repos_path/libexpat/expat"
$install_path = "$libs_path/libexpat/"
$build_path = "$source_path/build/"
Push-Location $repos_path
try
{
	Set-Location $repos_path
	get-git-repo.ps1 -git_url https://github.com/libexpat/libexpat.git

	New-Item -Path $build_path -ItemType Directory -Force | Out-Null
	# Remove-Item "$build_path/*" -Recurse -Force

	Create-Text-File -Path "$build_path/toolchain.cmake" `
		-Content @"
	set(CROSS_COMPILE_ARM 1)
	set(CMAKE_SYSTEM_NAME Linux)
	set(CMAKE_SYSTEM_PROCESSOR armv7-a)

	set(CMAKE_C_COMPILER arm-none-linux-gnueabihf-gcc)
	set(CMAKE_CXX_COMPILER arm-none-linux-gnueabihf-g++)

	$(Get-Cmake-Set-Find-Lib-Path-String)
"@

	Set-Location $build_path
	cmake -G "Ninja" $source_path `
		-DCMAKE_TOOLCHAIN_FILE="$build_path/toolchain.cmake" `
		-DCMAKE_INSTALL_PREFIX="$install_path" `
		-DEXPAT_BUILD_DOCS=OFF
	if ($LASTEXITCODE)
	{
		throw "配置失败"
	}
	
	ninja -j12
	if ($LASTEXITCODE)
	{
		throw "编译失败"
	}

	ninja install

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
