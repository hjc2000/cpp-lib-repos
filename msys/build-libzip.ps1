$build_script_path = Split-Path -Path $MyInvocation.MyCommand.Definition -Parent
. $build_script_path/../.base-script/prepare-for-building.ps1
. $build_script_path/../.base-script/prepare-for-msys.ps1

$source_path = "$repos_path/libzip"
$install_path = "$libs_path/libzip"
$build_path = "$source_path/jc_build/"
if (Test-Path -Path $install_path)
{
	Write-Host "$install_path 已存在，不编译，直接返回。如需编译，请先删除目录。"
	return 0
}

Push-Location $repos_path
try
{
	Build-Dependency "build-zlib.ps1"
	Build-Dependency "build-bzip2.ps1"
	Build-Dependency "build-xz.ps1"
	Build-Dependency "build-zstd.ps1"

	git-get-repo.ps1 -git_url "https://github.com/nih-at/libzip.git"


	New-Empty-Dir $build_path
	Set-Location $build_path
	cmake -G "Ninja" $source_path `
		-DCMAKE_C_COMPILER="gcc" `
		-DCMAKE_CXX_COMPILER="g++" `
		-DCMAKE_BUILD_TYPE=Release `
		-DCMAKE_INSTALL_PREFIX="$install_path"
		
	if ($LASTEXITCODE)
	{
		throw "$source_path 配置失败"
	}
	
	ninja -j12
	if ($LASTEXITCODE)
	{
		throw "$source_path 编译失败"
	}

	ninja install | Out-Null

	Install-Msys-Dlls @(
		"/ucrt64/bin/libzstd.dll"
	)
	Install-Dependent-Dlls-From-Dir -dll_dir "$libs_path/zlib/bin"
	Install-Dependent-Dlls-From-Dir -dll_dir "$libs_path/bzip2/bin"
	Install-Dependent-Dlls-From-Dir -dll_dir "$libs_path/xz/bin"
	Install-Dependent-Dlls-From-Dir -dll_dir "$libs_path/zstd/bin"
	Install-Lib -src_path $install_path -dst_path $total_install_path
	Install-Lib -src_path $install_path -dst_path $(cygpath.exe /ucrt64 -w)
	Auto-Ldd $install_path/bin
}
finally
{
	Pop-Location
}
