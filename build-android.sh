#!/bin/bash

# ./build-android.sh ANDROID_VERSION

args=("$@")
ANDROID_VERSION=${args[0]} || 26

# Make sure ANDROID_NDK_HOME set in .bash_profile.
NDK=$ANDROID_NDK_HOME
ARCH=`ls $NDK/toolchains/aarch64-linux-android-4.9/prebuilt/`
PREBUILT=$NDK/toolchains/aarch64-linux-android-4.9/prebuilt/${ARCH}
PLATFORM=$NDK/platforms/android-$ANDROID_VERSION/arch-arm64/
SYSROOT=$NDK/sysroot

GENERAL="\
--enable-small \
--enable-cross-compile \
--extra-libs="-lgcc" \
--arch=aarch64 \
--cc=$PREBUILT/bin/aarch64-linux-android-gcc \
--cross-prefix=$PREBUILT/bin/aarch64-linux-android- \
--nm=$PREBUILT/bin/aarch64-linux-android-nm \
--extra-cflags=-I./deps/opus/include \
--extra-cflags=-I$SYSROOT/usr/include/aarch64-linux-android \
--extra-cflags=-isystem $SYSROOT/usr/include/aarch64-linux-android \
--extra-cflags="-DANDROID" "

# MODULES="\
# --enable-gpl \
# --enable-libx264"

function build_arm64
{
  echo "Configuring..."
  ./configure --disable-everything --disable-all --disable-doc --disable-htmlpages --disable-manpages --disable-podpages --disable-txtpages --disable-static --enable-avcodec --enable-avformat --enable-avutil --enable-fft --enable-rdft --enable-static --enable-libopus --disable-debug --disable-bzlib --disable-error-resilience --disable-iconv --disable-lzo --disable-network --disable-schannel --disable-sdl2 --disable-symver --disable-xlib --disable-zlib --disable-securetransport --disable-faan --disable-alsa --disable-autodetect --enable-decoder='vorbis,libopus,flac' --enable-decoder='pcm_u8,pcm_s16le,pcm_s24le,pcm_s32le,pcm_f32le,mp3' --enable-decoder='pcm_s16be,pcm_s24be,pcm_mulaw,pcm_alaw' --enable-demuxer='ogg,matroska,wav,flac,mp3,mov' --enable-parser='opus,vorbis,flac,mpegaudio' \
  --disable-linux-perf --x86asmexe=yasm --enable-small --enable-cross-compile \
  --logfile=conflog.txt \
  --target-os=android --arch=aarch64 --enable-armv8 --extra-cflags='-march=armv8-a' --enable-pic --enable-avfilter --enable-swscale --enable-swresample --enable-avdevice \
  --prefix=./android/arm64-v8a \
  ${GENERAL} \
  --sysroot=$SYSROOT \
  --extra-cflags="" \
  --extra-ldflags="-Wl,-rpath-link=$PLATFORM/usr/lib -L$PLATFORM/usr/lib -nostdlib -lc -lm -ldl -llog" \
  --enable-shared \
  --enable-demuxer=aac --enable-parser=aac --enable-decoder=aac

  $NDK/prebuilt/$ARCH/bin/make clean
  $NDK/prebuilt/$ARCH/bin/make
  $NDK/prebuilt/$ARCH/bin/make install
}

build_arm64

echo Android ARM64 builds finished
