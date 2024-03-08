$build_script_path = Split-Path -Path $MyInvocation.MyCommand.Definition -Parent
. $build_script_path/../.base-script/prepare-for-building.ps1

$source_path = "$repos_path/x264/"
$install_path = "$libs_path/x264"
Push-Location $repos_path
try
{
	get-git-repo.ps1 -git_url "https://gitee.com/Qianshunan/x264.git"

	# 执行命令进行构建
	run-bash-cmd.ps1 @"
	set -e
	cd $(cygpath.exe $source_path)

	./configure \
	--prefix="$(cygpath.exe $install_path)" \
	--enable-shared \
	--disable-opencl \
	--enable-pic

	make -j12
	make install
"@

	if ($LASTEXITCODE)
	{
		throw "$source_path 配置失败"
	}

	Install-Lib -src_path $install_path -dst_path $total_install_path
}
finally
{
	Pop-Location
}
