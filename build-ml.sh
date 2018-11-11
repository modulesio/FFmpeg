#!/bin/bash

set -e

export MLSDK=${MLSDK:-/mnt/c/Users/avaer/MagicLeap/mlsdk/v0.16.0}
# export MLSDK_WIN=$(echo "$MLSDK" | sed 's/^\/mnt\/c\//C:\\/' | sed 's/\//\\/g')

export TOOLCHAIN="$MLSDK/tools/toolchains/bin"
export CC="$TOOLCHAIN/aarch64-linux-android-clang"
export CXX="$TOOLCHAIN/aarch64-linux-android-clang++"
export LINK="$TOOLCHAIN/aarch64-linux-android-clang++"
export AR="$TOOLCHAIN/aarch64-linux-android-ar"
export SYSROOT="$MLSDK/lumin"
export PATH="$PATH:$TOOLCHAIN"
export TEMPDIR="$(pwd)/tmp"

../magicleap-js/hack-toolchain.js

# opus
pushd ./deps/opus
./autogen.sh
./configure --disable-shared --with-sysroot="$SYSROOT" --host="aarch64-linux-android"
find . -type f -iname '*.Plo' -exec sed -i 's/C:\\/\/mnt\/c\//gi' "{}" +;
find . -type f -iname '*.Plo' -exec sed -i 's/\([^ ]\)\\/\1\//gi' "{}" +;
find . -type f -iname '*.Po' -exec sed -i 's/C:\\/\/mnt\/c\//gi' "{}" +;
find . -type f -iname '*.Po' -exec sed -i 's/\([^ ]\)\\/\1\//gi' "{}" +;
make clean
make -j4
popd

# deps/x264/libx264.a
pushd ./deps/x264
./configure --enable-static --disable-opencl --enable-pic --sysroot="$SYSROOT" --cross-prefix="aarch64-linux-android-" --host="aarch64-linux-android"
make clean
make -j4
popd

# deps/lame/libmp3lame/.libs/libmp3lame.a
pushd ./deps/lame
./configure --enable-static --disable-shared --host="aarch64-linux-android" --build="x86_64-linux-gnu"
find . -type f -iname '*.Plo' -exec sed -i 's/C:\\/\/mnt\/c\//gi' "{}" +;
find . -type f -iname '*.Plo' -exec sed -i 's/\([^ ]\)\\/\1\//gi' "{}" +;
find . -type f -iname '*.Po' -exec sed -i 's/C:\\/\/mnt\/c\//gi' "{}" +;
find . -type f -iname '*.Po' -exec sed -i 's/\([^ ]\)\\/\1\//gi' "{}" +;
make clean
make -j4
mkdir -p include/lame
cp -f include/lame.h include/lame/lame.h
popd

# deps/rtmpdump/librtmp/librtmp.a
pushd ./deps/rtmpdump
make clean
make CRYPTO= SHARED= CROSS_COMPILE="aarch64-linux-android-" THREADLIB= -j4
popd

mkdir "$TEMPDIR"
 
# https://chromium.googlesource.com/chromium/third_party/ffmpeg/+/master/chromium/config/Chrome/linux/x64/config.h
./configure --enable-cross-compile --sysroot="$SYSROOT" --cross-prefix="aarch64-linux-android-" --extra-cflags="-I$MLSDK/lumin/stl/libc++/include" --extra-cflags="-I$MLSDK/lumin/usr/include" --extra-cflags='--target=aarch64-linux-android' --extra-cflags='-DLUMIN' --extra-ldflags='--target=aarch64-linux-android' --extra-ldflags="--gcc-toolchain=$MLSDK/tools/toolchains/bin" --target-os=android --arch=aarch64 --enable-armv8 --extra-cflags='-march=armv8-a' --cc="$MLSDK/tools/toolchains/bin/aarch64-linux-android-gcc" --cxx="$MLSDK/tools/toolchains/bin/aarch64-linux-android-g++" --ld="$MLSDK/tools/toolchains/bin/aarch64-linux-android-ld" \
--disable-everything --disable-all --enable-pic --enable-avfilter --enable-swscale --enable-swresample --enable-avdevice \
--extra-libs=-lopus --extra-cflags="-Ideps/opus/include" --extra-ldflags="-Ldeps/opus/.libs" \
--extra-libs=-lmp3lame --extra-cflags="-Ideps/lame/include" --extra-ldflags="-Ldeps/lame/libmp3lame/.libs" \
--extra-libs=-lrtmp --extra-cflags="-Ideps/rtmpdump" --extra-ldflags="-Ldeps/rtmpdump/librtmp" \
--extra-libs=-lx264 --extra-cflags="-Ideps/x264" --extra-ldflags="-Ldeps/x264" \
--disable-doc --disable-htmlpages --disable-manpages --disable-podpages --disable-txtpages --disable-static --enable-avcodec --enable-avformat --enable-avutil --enable-fft --enable-rdft --enable-static --enable-libopus --disable-bzlib --disable-error-resilience --disable-iconv --disable-lzo --enable-network --disable-schannel --disable-sdl2 --disable-symver --disable-xlib --disable-zlib --disable-securetransport --disable-faan --disable-alsa --disable-autodetect --enable-gpl --enable-libx264 --enable-libmp3lame --enable-librtmp --enable-decoder='vorbis,libopus,flac' --enable-decoder='pcm_u8,pcm_s16le,pcm_s24le,pcm_s32le,pcm_f32le,mp3' --enable-decoder='pcm_s16be,pcm_s24be,pcm_mulaw,pcm_alaw' --enable-demuxer='ogg,matroska,wav,flac,mp3,mov' --enable-muxer='flv' --enable-protocol='librtmp' --enable-parser='opus,vorbis,flac,mpegaudio' --enable-encoder='libx264rgb,libmp3lame' --disable-linux-perf --optflags='\"-O3\"' --enable-decoder='theora,vp8' --enable-parser='vp3,vp8' --enable-decoder='aac,h264' --enable-demuxer=aac --enable-parser='aac,h264'
sed -i 's/HAVE_CLOSESOCKET 1/HAVE_CLOSESOCKET 0/g' config.h
sed -i 's/HAVE_SYSCTL 1/HAVE_SYSCTL 0/g' config.h
sed -i 's/HAVE_GETHRTIME 1/HAVE_GETHRTIME 0/g' config.h
find . -type f -iname '*.d' -exec sed -i 's/C:\\/\/mnt\/c\//gi' "{}" +;
find . -type f -iname '*.d' -exec sed -i 's/\([^ ]\)\\/\1\//gi' "{}" +;
make clean
make -j4
# npm install
