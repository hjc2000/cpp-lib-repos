$build_script_path = Split-Path -Path $MyInvocation.MyCommand.Definition -Parent
. $build_script_path/../.base-script/prepare-for-building.ps1

$source_path = "$repos_path/xz/"
$install_path = "$libs_path/xz/"
$build_path = "$source_path/build"
Push-Location $repos_path
try
{
	get-git-repo.ps1 -git_url https://github.com/tukaani-project/xz.git `
		-branch_name v5.6

	New-Empty-Dir $build_path
	cmake -G "Ninja" $source_path `
		-DCMAKE_BUILD_TYPE=Release `
		-DCMAKE_INSTALL_PREFIX="${install_path}" `
		-DBUILD_SHARED_LIBS=ON

	if ($LASTEXITCODE)
	{
		throw "$source_path 配置失败"
	}
	
	ninja -j12
	if ($LASTEXITCODE)
	{
		throw "$source_path 编译失败"
	}

	ninja install

	# 修复 .pc 文件内的路径
	Fix-PC-Config-PC-File "${install_path}/lib/pkgconfig/liblzma.pc"

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