$build_script_path = Split-Path -Path $MyInvocation.MyCommand.Definition -Parent
. $build_script_path/../.base-script/prepare-for-building.ps1

$source_path = "$repos_path/mesa/src/egl"
$install_path = "$libs_path/egl/"
$build_path = "$source_path/build/"
Push-Location $repos_path
try
{
	# 开始构建本体
	Set-Location $repos_path
	get-git-repo.ps1 -git_url "https://github.com/Mesa3D/mesa.git"

	New-Item -Path $build_path -ItemType Directory -Force | Out-Null
	Remove-Item "$build_path/*" -Recurse -Force

	New-Meson-Cross-File
	Set-Location $source_path
	meson setup build/ `
		--prefix="$install_path" `
		--cross-file="$build_path/cross_file.ini"
		
	if ($LASTEXITCODE)
	{
		throw "$source_path 配置失败"
	}
	
	Set-Location $build_path
	ninja -j12
	if ($LASTEXITCODE)
	{
		throw "$source_path 编译失败"
	}

	ninja install

	Install-Lib -src_path $install_path -dst_path $total_install_path
}
finally
{
	Pop-Location
}
