#!/bin/bash -e

. ../../include/depinfo.sh
. ../../include/path.sh

build=_build$ndk_suffix

if [ "$1" == "build" ]; then
	true
elif [ "$1" == "clean" ]; then
	rm -rf $build
	exit 0
else
	exit 255
fi

unset CC CXX # meson wants these unset

CFLAGS="-Wno-error -Wno-error=implicit-function-declaration -O3 -mcpu=oryon-1 -fno-plt -pipe -fvectorize -funroll-loops -flto=auto -fPIC" CXXFLAGS="-Wno-error -Wno-error=implicit-function-declaration -O3 -mcpu=oryon-1 -fno-plt -pipe -fvectorize -funroll-loops -flto=auto -fPIC" meson setup $build --cross-file "$prefix_dir"/crossfile.txt

ninja -C $build -j$cores
DESTDIR="$prefix_dir" ninja -C $build install
