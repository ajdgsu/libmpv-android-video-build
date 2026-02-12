#!/bin/bash -e

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && cd .. && pwd )"

. $DIR/include/depinfo.sh
. $DIR/include/path.sh

if [ "$1" == "build" ]; then
    true
elif [ "$1" == "clean" ]; then
    rm -rf _build$ndk_suffix
    exit 0
else
    exit 255
fi

# Get prefix directory
prefix_dir="${DIR}/prefix/arm64-v8a"

# Create build directory
mkdir -p "${DIR}/deps/libplacebo/_build"
cd "${DIR}/deps/libplacebo"

# Set cross-compilation environment variables
export CC="aarch64-linux-android30-clang"
export CXX="aarch64-linux-android30-clang++"
export AR="llvm-ar"
export LD="ld.lld"
export RANLIB="llvm-ranlib"
export STRIP="llvm-strip"
export NM="llvm-nm"

export PKG_CONFIG_PATH="${prefix_dir}/lib/pkgconfig:${prefix_dir}/usr/local/lib/pkgconfig:${PKG_CONFIG_PATH:-}"

# Create cross-file for meson
mkdir -p "${DIR}/scripts/cross"
cat > "${DIR}/scripts/cross/arm64-v8a.ini" << EOF
[binaries]
c = 'aarch64-linux-android30-clang'
cpp = 'aarch64-linux-android30-clang++'
ar = 'llvm-ar'
strip = 'llvm-strip'
ld = 'ld.lld'
pkg-config = 'pkg-config'

[host_machine]
system = 'android'
cpu_family = 'aarch64'
cpu = 'armv8-a'
endian = 'little'

[built-in options]
buildtype = 'release'
default_library = 'static'
wrap_mode = 'nodownload'
EOF

# Clean previous build
rm -rf _build

meson setup _build --prefix="${prefix_dir}" \
    --default-library=static \
    --buildtype=release \
    --cross-file="${DIR}/scripts/cross/arm64-v8a.ini" \
    -Ddemos=false \
    -Dtests=false \
    -Dshaderc=disabled \
    -Dvulkan=disabled \
    -Dopengl=disabled \
    -Dlcms=disabled \
    -Ddovi=disabled

meson compile -C _build -j "$cores"
meson install -C _build

cd "${DIR}"
