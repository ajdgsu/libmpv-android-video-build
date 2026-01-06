#!/bin/bash

. ../../include/depinfo.sh
. ../../include/path.sh

if [ "$1" == "build" ]; then
    true
elif [ "$1" == "clean" ]; then
    rm -rf _build$ndk_suffix
    exit 0
else
    exit 255
fi

[ -f configure ] || ./autogen.sh

make distclean 2>/dev/null || true

# Debug: Check if mbedtls headers are installed
echo "Checking for mbedtls headers in $prefix_dir/include/mbedtls/"
ls -la $prefix_dir/include/mbedtls/ 2>/dev/null || echo "No mbedtls headers found"

mkdir -p _build$ndk_suffix
cd _build$ndk_suffix

# FFmpeg configuration for Android arm64 cross-compilation
CC="$CC" \
CXX="$CXX" \
AR="llvm-ar" \
RANLIB="llvm-ranlib" \
NM="llvm-nm" \
../configure \
--prefix="$prefix_dir" \
--target-os=android \
--arch=aarch64 \
--cpu=oryon-1 \
--cross-prefix="$ndk_triple-" \
--sysroot="$ndk_sysroot" \
--enable-cross-compile \
--enable-static \
--disable-shared \
--disable-doc \
--disable-programs \
--disable-avdevice \
--enable-avfilter \
--disable-encoders \
--disable-decoders \
--disable-muxers \
--disable-demuxers \
--disable-parsers \
--disable-protocols \
--disable-filters \
--disable-bsfs \
--enable-mbedtls \
--enable-version3 \
--enable-protocol=file \
--enable-demuxer=matroska,webm \
--enable-decoder=av1,vorbis \
--enable-parser=av1,vorbis \
--extra-cflags="$CFLAGS -I$prefix_dir/include -I$prefix_dir/include/mbedtls/private" \
--extra-ldflags="$LDFLAGS -L$prefix_dir/lib" \
--cc="$CC" \
--cxx="$CXX" \
--nm="llvm-nm" \
--ar="llvm-ar" \
--ranlib="llvm-ranlib"

make -j$(nproc)
make install