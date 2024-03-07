$build_script_path = Split-Path -Path $MyInvocation.MyCommand.Definition -Parent
. $build_script_path/../.base-script/prepare-for-building.ps1

$source_path = "$repos_path/FFmpeg/"
$install_path = "$libs_path/ffmpeg/"
Push-Location $repos_path
try
{
	# 构建依赖项
	& "${build_script_path}/build-x264.ps1"
	& "${build_script_path}/build-x265.ps1"
	& "${build_script_path}/build-openssl.ps1"
	& "${build_script_path}/build-sdl2.ps1"
	# 设置依赖项的 pkg-config
	$env:PKG_CONFIG_PATH = "$total_install_path/lib"
	Total-Install


	Set-Location $repos_path
	get-git-repo.ps1 -git_url "https://github.com/FFmpeg/FFmpeg.git"


	$env:PATH = "$libs_path/sdl2/bin/:$env:PATH"
	Copy-Item -Path "$libs_path/sdl2/bin/sdl2-config" `
		-Destination "$libs_path/sdl2/bin/arm-none-linux-gnueabihf-sdl2-config"


	run-bash-cmd.ps1 @"
	cd $source_path

	./configure \
	--prefix="$install_path" \
	--enable-libx264 \
	--enable-libx265 \
	--enable-openssl \
	--enable-sdl \
	--enable-gpl \
	--enable-version3 \
	--enable-pic \
	--enable-shared \
	--disable-static \
	--enable-cross-compile \
	--cross-prefix="arm-none-linux-gnueabihf-" \
	--arch="arm" \
	--target-os="linux" \
	--pkg-config="pkg-config"

	make clean
	make -j12
	make install
"@

	if ($LASTEXITCODE)
	{
		throw "编译失败"
	}

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
