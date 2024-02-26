param (
	[string]$libs_path = $env:libs_path,
	[string]$repos_path = $env:repos_path,
	[string]$cpp_lib_build_scripts_path = $env:cpp_lib_build_scripts_path
)
$ErrorActionPreference = "Stop"

Push-Location $repos_path
get-git-repo.ps1 -git_url "https://gitee.com/Qianshunan/x264.git"
$source_path = "$repos_path/x264/"
$install_path = "$libs_path/x264"
Set-Location $source_path

run-bash-cmd.ps1 @"
set -e
cd $(cygpath.exe $source_path)

./configure \
--prefix="$(cygpath.exe $install_path)" \
--enable-shared \
--disable-opencl \
--enable-pic

make clean
make -j12
make install
"@

Write-Host "`n`n`n========================================"
Write-Host "pc 文件的内容："
Get-Content "$install_path/lib/pkgconfig/x264.pc"
Pop-Location