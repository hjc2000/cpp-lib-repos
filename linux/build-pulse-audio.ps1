$build_script_path = Split-Path -Path $MyInvocation.MyCommand.Definition -Parent
. $build_script_path/../.base-script/prepare-for-building.ps1

$source_path = "$repos_path/pulseaudio/"
$install_path = "$libs_path/pulseaudio/"
$build_path = "$source_path/build/"
Push-Location $repos_path
try
{
	# 构建依赖项
	& $build_script_path/build-libsndfile.ps1
	& $build_script_path/build-glib.ps1
	Write-Host $env:PKG_CONFIG_PATH
	return

	# 开始构建本体
	Set-Location $repos_path
	get-git-repo.ps1 -git_url "https://github.com/pulseaudio/pulseaudio.git"

	Set-Location $source_path
	meson setup build/ `
		--prefix=$install_path `
		-Ddaemon=false `
		-Dtests=false `
		-Ddoxygen=false

	run-bash-cmd.ps1 @"
	cd $build_path
	ninja -j12

	sudo su
	ninja install
	chmod 777 -R $install_path
	exit
"@
}
catch
{
	throw
}
finally
{
	Pop-Location
}
