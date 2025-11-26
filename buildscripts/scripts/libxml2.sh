#!/bin/bash -e

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

mkdir -p _build$ndk_suffix
cd _build$ndk_suffix

export ac_cv_header_sys_timeb_h=no

../configure \
    CFLAGS="-O3 -mcpu=cortex-a725 -fno-plt -pipe -fvectorize -funroll-loops -mllvm -polly -mllvm -polly-run-inliner -mllvm -polly-ast-use-context -mllvm -polly-detect-keep-going -mllvm -polly-invariant-load-hoisting -mllvm -polly-vectorizer=stripmine -mllvm -polly-loopfusion-greedy=1 -mllvm -polly-reschedule=1 -mllvm -polly-postopts=1 -mllvm -polly-run-dce -mllvm -hot-cold-split=true -flto=auto -fPIC" CXXFLAGS="-O3 -mcpu=cortex-a725 -fno-plt -pipe -fvectorize -funroll-loops -mllvm -polly -mllvm -polly-run-inliner -mllvm -polly-ast-use-context -mllvm -polly-detect-keep-going -mllvm -polly-invariant-load-hoisting -mllvm -polly-vectorizer=stripmine -mllvm -polly-loopfusion-greedy=1 -mllvm -polly-reschedule=1 -mllvm -polly-postopts=1 -mllvm -polly-run-dce -mllvm -hot-cold-split=true -flto=auto -fPIC" \
	LIBS="-ldl" \
	--host=aarch64-linux-android \
    --disable-shared \
    --enable-static \
    --with-minimum \
    --with-threads=no \
    --with-tree \
    --without-lzma

echo -e "\n-----------------\nconfig.log start\n-----------------\n"
find ../ -name "config.log" -exec cat {} \;
echo -e "\n-----------------\nconfig.log end\n-----------------\n"

make -j$cores
make DESTDIR="$prefix_dir" install
