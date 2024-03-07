$build_script_path = Split-Path -Path $MyInvocation.MyCommand.Definition -Parent
. $build_script_path/../.base-script/prepare-for-building.ps1

$source_path = "$repos_path/libffi/libffi-3.4.6"
$install_path = "$libs_path/libffi/"
Push-Location $repos_path

try
{
	Set-Location $repos_path
	wget-repo.ps1 -workspace_dir $repos_path `
		-repo_url "https://github.com/libffi/libffi/releases/download/v3.4.6/libffi-3.4.6.tar.gz" `
		-out_dir_name "libffi"

	run-bash-cmd.ps1 @"
	cd $source_path

	./configure \
	--prefix=$install_path \
	--host=arm-none-linux-gnueabihf \
	--target=arm-none-linux-gnueabihf

	make -j12
	make install
"@
	if ($LASTEXITCODE)
	{
		throw "$source_path 编译失败"
	}

	Install-Lib -src_path $install_path -dst_path $total_install_path
}
finally
{
	Pop-Location
}