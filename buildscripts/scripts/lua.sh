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

mkdir -p _build$ndk_suffix
cd _build$ndk_suffix

# Lua uses a custom makefile system, we need to set the appropriate variables
make -C ../ \
	CC="$CC" \
	AR="$AR rcu" \
	RANLIB="$RANLIB" \
	MYCFLAGS="-Wno-error -Wno-error=implicit-function-declaration -O3 -mcpu=oryon-1 -fno-plt -pipe -fvectorize -funroll-loops -fPIC" \
	MYLDFLAGS="-Wl,-O1,--icf=safe -Wl,-z,max-page-size=16384 -Wl,--sort-common -Wl,--as-needed -Wl,-z,pack-relative-relocs" \
	PLAT=generic

make -C ../ \
	CC="$CC" \
	AR="$AR rcu" \
	RANLIB="$RANLIB" \
	MYCFLAGS="-Wno-error -Wno-error=implicit-function-declaration -O3 -mcpu=oryon-1 -fno-plt -pipe -fvectorize -funroll-loops -fPIC" \
	MYLDFLAGS="-Wl,-O1,--icf=safe -Wl,-z,max-page-size=16384 -Wl,--sort-common -Wl,--as-needed -Wl,-z,pack-relative-relocs" \
	PLAT=generic \
	INSTALL_TOP="$prefix_dir" \
	install

# Create pkg-config file for Lua
mkdir -p "$prefix_dir/lib/pkgconfig"
cat > "$prefix_dir/lib/pkgconfig/lua5.2.pc" <<EOF
prefix=$prefix_dir
exec_prefix=
libdir=
includedir=

Name: Lua
Description: An Extensible Extension Language
Version: 5.2.4
Libs: -L\${prefix_dir}/lib -llua
Cflags: -I\${prefix_dir}/include
EOF