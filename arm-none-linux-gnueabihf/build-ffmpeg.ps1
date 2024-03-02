$build_script_path = Split-Path -Path $MyInvocation.MyCommand.Definition -Parent
. $build_script_path/../.base-script/prepare-for-building.ps1

$source_path = "$repos_path/FFmpeg/"
$install_path = "$libs_path/ffmpeg/"
Push-Location $repos_path
try
{
	Import-Lib -LibName "x264" -NotBuild
	Import-Lib -LibName "x265" -NotBuild
	Import-Lib -LibName "sdl2" -NotBuild
	Import-Lib -LibName "amf" -NotBuild
	Import-Lib -LibName "openssl" -NotBuild
	Write-Host "PKG_CONFIG_PATH 的值：$env:PKG_CONFIG_PATH"

	Set-Location $repos_path
	get-git-repo.ps1 -git_url "https://github.com/FFmpeg/FFmpeg.git"

	run-bash-cmd.ps1 @"
	cd $source_path

	./configure \
	--prefix="$install_path" \
	--extra-cflags="-I$libs_path/amf/include/ -I/home/hjc/cpp-lib-build-scripts/arm-none-linux-gnueabihf/.libs/sdl2/include -I/home/hjc/cpp-lib-build-scripts/arm-none-linux-gnueabihf/.libs/sdl2/include/SDL2" \
	--extra-libs="-L/home/hjc/cpp-lib-build-scripts/arm-none-linux-gnueabihf/.libs/sdl2/lib -Wl,-rpath,/home/hjc/cpp-lib-build-scripts/arm-none-linux-gnueabihf/.libs/sdl2/lib -Wl,--enable-new-dtags -lSDL2" \
	--enable-sdl \
	--enable-libx264 \
	--enable-libx265 \
	--enable-openssl \
	--enable-version3 \
	--enable-amf \
	--enable-pic \
	--enable-gpl \
	--enable-shared \
	--disable-static \
	--enable-cross-compile \
	--cross-prefix="arm-none-linux-gnueabihf-" \
	--arch="arm" \
	--target-os="linux" \
	--pkg-config="$(which pkg-config)"

	make clean
	make -j12
	make install
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
