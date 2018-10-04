#!/bin/bash

pushd ./deps/opus
./autogen.sh
./configure --disable-shared
make clean
make -j4
popd

# deps/x264/libx264.a
pushd ./deps/x264
./configure --enable-static --disable-shared --disable-opencl --enable-pic
make clean
make -j4
popd

# deps/lame/libmp3lame/.libs/libmp3lame.a
pushd ./deps/lame
./configure --enable-static --disable-shared
make clean
make -j4
cd include
mkdir lame
cd lame
ln -s ../lame.h .
popd

# deps/rmpdump/librtmp/librtmp.a
pushd ./deps/rmpdump
make clean
make CRYPTO= SHARED= -j4
popd

# https://chromium.googlesource.com/chromium/third_party/ffmpeg/+/master/chromium/config/Chrome/linux/x64/config.h
./configure --disable-everything --disable-all --enable-pic --enable-avfilter --enable-swscale --enable-swresample --enable-avdevice \
--extra-libs=-lopus --extra-cflags="-I./deps/opus/include" --extra-ldflags="-L./deps/opus/.libs" \
--extra-libs=-lmp3lame --extra-cflags="-I./deps/lame/include" --extra-ldflags="-L./deps/lame/libmp3lame/.libs" \
--extra-libs=-lrtmp --extra-cflags="-I./deps/rtmpdump" --extra-ldflags="-L./deps/rtmpdump/librtmp" \
--extra-libs=-lx264 --extra-cflags="-I./deps/x264" --extra-ldflags="-L./deps/x264" \
--disable-doc --disable-htmlpages --disable-manpages --disable-podpages --disable-txtpages --disable-static --enable-avcodec --enable-avformat --enable-avutil --enable-fft --enable-rdft --enable-static --enable-libopus --disable-bzlib --disable-error-resilience --disable-iconv --disable-lzo --enable-network --disable-schannel --disable-sdl2 --disable-symver --disable-xlib --disable-zlib --disable-securetransport --disable-faan --disable-alsa --disable-autodetect --enable-gpl --enable-libx264 --enable-libmp3lame --enable-librtmp --enable-decoder='vorbis,libopus,flac' --enable-decoder='pcm_u8,pcm_s16le,pcm_s24le,pcm_s32le,pcm_f32le,mp3' --enable-decoder='pcm_s16be,pcm_s24be,pcm_mulaw,pcm_alaw' --enable-demuxer='ogg,matroska,wav,flac,mp3,mov,flv' --enable-muxer='flv' --enable-protocol='librtmp' --enable-parser='opus,vorbis,flac,mpegaudio,flv' --enable-encoder='libx264,libx264rgb,libmp3lame' --disable-linux-perf --optflags='\"-O2\"' --enable-decoder='theora,vp8' --enable-parser='vp3,vp8' --enable-decoder='aac,h264' --enable-demuxer=aac --enable-parser='aac,h264' --disable-asm
make clean
make -j4
# npm install
