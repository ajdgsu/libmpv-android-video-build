#!/bin/bash

set -e

# Get number of CPU cores
cores=$(nproc)

# Get source directory
src_dir=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)

# Get prefix directory
prefix_dir="${src_dir}/../prefix"

# Create build directory
mkdir -p "${src_dir}/_build/libplacebo"
cd "${src_dir}/_build/libplacebo"

# Clone libplacebo if not already present
if [ ! -d "libplacebo" ]; then
    git clone --depth 1 --branch v6.338.2 https://code.videolan.org/videolan/libplacebo.git
fi

cd libplacebo

# Set cross-compilation environment variables with full path
export CC="/home/ajdgsu/source/libmpv-android-video-build/buildscripts/sdk/android-sdk-linux/ndk/29.0.14206865/toolchains/llvm/prebuilt/linux-x86_64/bin/aarch64-linux-android30-clang"
export CXX="/home/ajdgsu/source/libmpv-android-video-build/buildscripts/sdk/android-sdk-linux/ndk/29.0.14206865/toolchains/llvm/prebuilt/linux-x86_64/bin/aarch64-linux-android30-clang++"
export AR="/home/ajdgsu/source/libmpv-android-video-build/buildscripts/sdk/android-sdk-linux/ndk/29.0.14206865/toolchains/llvm/prebuilt/linux-x86_64/bin/llvm-ar"
export LD="/home/ajdgsu/source/libmpv-android-video-build/buildscripts/sdk/android-sdk-linux/ndk/29.0.14206865/toolchains/llvm/prebuilt/linux-x86_64/bin/ld.lld"
export RANLIB="/home/ajdgsu/source/libmpv-android-video-build/buildscripts/sdk/android-sdk-linux/ndk/29.0.14206865/toolchains/llvm/prebuilt/linux-x86_64/bin/llvm-ranlib"
export STRIP="/home/ajdgsu/source/libmpv-android-video-build/buildscripts/sdk/android-sdk-linux/ndk/29.0.14206865/toolchains/llvm/prebuilt/linux-x86_64/bin/llvm-strip"
export NM="/home/ajdgsu/source/libmpv-android-video-build/buildscripts/sdk/android-sdk-linux/ndk/29.0.14206865/toolchains/llvm/prebuilt/linux-x86_64/bin/llvm-nm"
export OBJCOPY="/home/ajdgsu/source/libmpv-android-video-build/buildscripts/sdk/android-sdk-linux/ndk/29.0.14206865/toolchains/llvm/prebuilt/linux-x86_64/bin/llvm-objcopy"
export OBJDUMP="/home/ajdgsu/source/libmpv-android-video-build/buildscripts/sdk/android-sdk-linux/ndk/29.0.14206865/toolchains/llvm/prebuilt/linux-x86_64/bin/llvm-objdump"

export PKG_CONFIG_PATH="${prefix_dir}/arm64-v8a/lib/pkgconfig:${prefix_dir}/arm64-v8a/usr/local/lib/pkgconfig:${PKG_CONFIG_PATH:-}"

# Use cross-compilation with meson
# Create cross-file if it doesn't exist
if [ ! -f "${src_dir}/cross/arm64-v8a.ini" ]; then
    mkdir -p "${src_dir}/cross"
    cat > "${src_dir}/cross/arm64-v8a.ini" << 'EOF'
[binaries]
c = '/home/ajdgsu/source/libmpv-android-video-build/buildscripts/sdk/android-sdk-linux/ndk/29.0.14206865/toolchains/llvm/prebuilt/linux-x86_64/bin/aarch64-linux-android30-clang'
cpp = '/home/ajdgsu/source/libmpv-android-video-build/buildscripts/sdk/android-sdk-linux/ndk/29.0.14206865/toolchains/llvm/prebuilt/linux-x86_64/bin/aarch64-linux-android30-clang++'
ar = '/home/ajdgsu/source/libmpv-android-video-build/buildscripts/sdk/android-sdk-linux/ndk/29.0.14206865/toolchains/llvm/prebuilt/linux-x86_64/bin/llvm-ar'
strip = '/home/ajdgsu/source/libmpv-android-video-build/buildscripts/sdk/android-sdk-linux/ndk/29.0.14206865/toolchains/llvm/prebuilt/linux-x86_64/bin/llvm-strip'
ld = '/home/ajdgsu/source/libmpv-android-video-build/buildscripts/sdk/android-sdk-linux/ndk/29.0.14206865/toolchains/llvm/prebuilt/linux-x86_64/bin/ld.lld'

[host_machine]
system = 'android'
cpu_family = 'aarch64'
cpu = 'armv8-a'
endian = 'little'
EOF
fi

meson setup build --prefix="${prefix_dir}/arm64-v8a" \
    --default-library=static \
    --buildtype=release \
    --cross-file="${src_dir}/cross/arm64-v8a.ini" \
    -Ddemos=false \
    -Dtests=false \
    -Dshaderc=disabled \
    -Dvulkan=disabled \
    -Dopengl=disabled

meson compile -C build -j "${cores}"
meson install -C build

cd "${src_dir}"