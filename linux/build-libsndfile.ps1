$build_script_path = Split-Path -Path $MyInvocation.MyCommand.Definition -Parent
. $build_script_path/../base-script/prepare-for-building.ps1

$source_path = "$repos_path/libsndfile/"
$install_path = "$libs_path/libsndfile/"
$build_path = "$source_path/build/"
Push-Location $repos_path
try
{
	get-git-repo.ps1 -git_url "https://github.com/libsndfile/libsndfile.git"

	New-Empty-Dir $build_path
	Set-Location $build_path
	cmake -G "Ninja" $source_path `
		-DCMAKE_BUILD_TYPE=Release `
		-DCMAKE_INSTALL_PREFIX="$install_path" `
		-DBUILD_SHARED_LIBS=ON

	ninja -j12
	ninja install
}
catch
{
	throw
}
finally
{
	Pop-Location
}