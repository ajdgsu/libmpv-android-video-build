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

cp ../../scripts/libvorbis.build meson.build
# -mno-ieee-fp is not supported by clang
sed s/\-mno\-ieee\-fp// -i {configure,configure.ac}

unset CC CXX # meson wants these unset

CFLAGS="-Wno-error -Wno-error=implicit-function-declaration -O3 -mcpu=oryon-1 -fno-plt -pipe -fvectorize -funroll-loops -fPIC" CXXFLAGS="-Wno-error -Wno-error=implicit-function-declaration -O3 -mcpu=oryon-1 -fno-plt -pipe -fvectorize -funroll-loops -fPIC" meson setup $build --cross-file "$prefix_dir"/crossfile.txt -Ddefault_library=static

meson compile -C $build libvorbis
DESTDIR="$prefix_dir" ninja -C $build install
