#!/bin/bash

# Don't forget to install yasm.

set -e

# Set your own NDK here
NDK=$ANDROID_NDK

ARM_PLATFORM=$NDK/platforms/android-27/arch-arm/
ARM_PREBUILT=$NDK/toolchains/arm-linux-androideabi-4.9/prebuilt/darwin-x86_64

ARM64_PLATFORM=$NDK/platforms/android-27/arch-arm64/
ARM64_PREBUILT=$NDK/toolchains/aarch64-linux-android-4.9/prebuilt/linux-x86_64

X86_PLATFORM=$NDK/platforms/android-27/arch-x86/
X86_PREBUILT=$NDK/toolchains/x86-4.9/prebuilt/darwin-x86_64

X86_64_PLATFORM=$NDK/platforms/android-27/arch-x86_64/
X86_64_PREBUILT=$NDK/toolchains/x86_64-4.9/prebuilt/darwin-x86_64

MIPS_PLATFORM=$NDK/platforms/android-27/arch-mips/
MIPS_PREBUILT=$NDK/toolchains/mipsel-linux-android-4.9/prebuilt/darwin-x86_64

BUILD_DIR=`pwd`




function build_one
{
if [ $ARCH == "arm" ]
then
    PLATFORM=$ARM_PLATFORM
    PREBUILT=$ARM_PREBUILT
    HOST=arm-linux-androideabi
elif [ $ARCH == "arm64" ]
then
    PLATFORM=$ARM64_PLATFORM
    PREBUILT=$ARM64_PREBUILT
    HOST=aarch64-linux-android
elif [ $ARCH == "mips" ]
then
    PLATFORM=$MIPS_PLATFORM
    PREBUILT=$MIPS_PREBUILT
    HOST=mipsel-linux-android
#alexvas
elif [ $ARCH == "x86_64" ]
then
    PLATFORM=$X86_64_PLATFORM
    PREBUILT=$X86_64_PREBUILT
    HOST=x86_64-linux-android
else
    PLATFORM=$X86_PLATFORM
    PREBUILT=$X86_PREBUILT
    HOST=i686-linux-android
fi

./configure --target-os=linux \
    --incdir=$NDK/sysroot/usr/include \
    --libdir=$PLATFORM/usr/lib \
    --enable-cross-compile \
    --arch=$ARCH \
    --cc=$PREBUILT/bin/$HOST-gcc \
    --cross-prefix=$PREBUILT/bin/$HOST- \
    --nm=$PREBUILT/bin/$HOST-nm \
    --sysroot=$PLATFORM \
    --extra-cflags="-I$BUILD_DIR/include -I$NDK/sysroot/usr/include -I$NDK/sysroot/usr/include/aarch64-linux-android -fPIC -DANDROID -Wfatal-errors -Wno-deprecated $OPTIMIZE_CFLAGS" \
    --enable-small \
    --extra-ldflags="-L$BUILD_DIR/lib/$CPU" \
    --disable-static \
    --enable-shared \
    --disable-doc \
    --disable-programs \
    --disable-stripping \
    --disable-symver \
    --enable-pic \
    --enable-swscale \
    --enable-swresample \
    --pkg-config=/usr/local/bin/pkg-config \
    $ADDITIONAL_CONFIGURE_FLAG

make clean
make -j4
make install
# $PREBUILT/bin/$HOST-ar d libavcodec/libavcodec.a inverse.o
# $PREBUILT/bin/$HOST-ld -rpath-link=$PLATFORM/usr/lib -L$PLATFORM/usr/lib  -soname libffmpeg.so -shared -nostdlib  -z noexecstack -Bsymbolic --whole-archive --no-undefined -o libffmpeg.so libavcodec/libavcodec.a libavformat/libavformat.a libavutil/libavutil.a libswscale/libswscale.a -lc -lm -lz -ldl -llog  --dynamic-linker=/system/bin/linker $PREBUILT/lib/gcc/$HOST/4.9.x/libgcc.a
popd
}

#arm v5te
#CPU=armv5te
#ARCH=arm
#OPTIMIZE_CFLAGS="-marm -march=$CPU"
#PREFIX=$BUILD_DIR/$CPU
#ADDITIONAL_CONFIGURE_FLAG=
#build_one

#arm v6
#CPU=armv6
#ARCH=arm
#OPTIMIZE_CFLAGS="-marm -march=$CPU"
#PREFIX=`pwd`/ffmpeg-android/$CPU 
#ADDITIONAL_CONFIGURE_FLAG=
#build_one

#arm v7vfpv3
#CPU=armv7-a
#ARCH=arm
#OPTIMIZE_CFLAGS="-mfloat-abi=softfp -mfpu=vfpv3-d16 -marm -march=$CPU -D__thumb__ -mthumb"
#PREFIX=$BUILD_DIR/$CPU
#ADDITIONAL_CONFIGURE_FLAG=
#build_one

#arm v7vfp
#CPU=armv7-a
#ARCH=arm
#OPTIMIZE_CFLAGS="-mfloat-abi=softfp -mfpu=vfp -marm -march=$CPU "
#PREFIX=`pwd`/ffmpeg-android/$CPU-vfp
#ADDITIONAL_CONFIGURE_FLAG=
#build_one

#arm v7n
#CPU=armv7-a
#ARCH=arm
#OPTIMIZE_CFLAGS="-mfloat-abi=softfp -mfpu=neon -marm -march=$CPU -mtune=cortex-a8"
#PREFIX=$BUILD_DIR/$CPU
#ADDITIONAL_CONFIGURE_FLAG=
#build_one

#arm v6+vfp
#CPU=armv6
#ARCH=arm
#OPTIMIZE_CFLAGS="-DCMP_HAVE_VFP -mfloat-abi=softfp -mfpu=vfp -marm -march=$CPU"
#PREFIX=`pwd`/ffmpeg-android/${CPU}_vfp
#ADDITIONAL_CONFIGURE_FLAG=
#build_one

#arm64-v8a
CPU=arm64-v8a
ARCH=arm64
OPTIMIZE_CFLAGS=
PREFIX=$BUILD_DIR/$CPU
ADDITIONAL_CONFIGURE_FLAG=
build_one

#x86_64
#CPU=x86_64
#ARCH=x86_64
#OPTIMIZE_CFLAGS="-fomit-frame-pointer"
#PREFIX=$BUILD_DIR/$CPU
#ADDITIONAL_CONFIGURE_FLAG=
#build_one

#x86
# CPU=i686
# ARCH=i686
# OPTIMIZE_CFLAGS="-fomit-frame-pointer"
# PREFIX=$BUILD_DIR/$CPU
# ADDITIONAL_CONFIGURE_FLAG=
# build_one
