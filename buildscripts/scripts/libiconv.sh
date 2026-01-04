#!/bin/bash -e

export ac_cv_header_sys_timeb_h=no
#export host_alias=aarch64-linux-android
#export build_alias=x86_64-pc-linux-gnu

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

echo -e "\n-----------------\nconfigure help start\n-----------------\n"
../configure --help
echo -e "\n-----------------\nconfigure help end\n-----------------\n"

# Use simplified compiler flags to avoid compatibility issues
#CFLAGS="-Wno-error -Wno-error=implicit-function-declaration -O3 -mcpu=cortex-a725 -fno-plt -pipe -fvectorize -funroll-loops -mllvm -polly -mllvm -polly-run-inliner -mllvm -polly-ast-use-context -mllvm -polly-detect-keep-going -mllvm -polly-invariant-load-hoisting -mllvm -polly-vectorizer=stripmine -mllvm -polly-loopfusion-greedy=1 -mllvm -polly-reschedule=1 -mllvm -polly-postopts=1 -mllvm -polly-run-dce -mllvm -hot-cold-split=true -fPIC"
#CXXFLAGS="-Wno-error -Wno-error=implicit-function-declaration -O3 -mcpu=cortex-a725 -fno-plt -pipe -fvectorize -funroll-loops -mllvm -polly -mllvm -polly-run-inliner -mllvm -polly-ast-use-context -mllvm -polly-detect-keep-going -mllvm -polly-invariant-load-hoisting -mllvm -polly-vectorizer=stripmine -mllvm -polly-loopfusion-greedy=1 -mllvm -polly-reschedule=1 -mllvm -polly-postopts=1 -mllvm -polly-run-dce -mllvm -hot-cold-split=true -fPIC"
CFLAGS="-Wno-error -Wno-error=implicit-function-declaration -O3 -mcpu=cortex-a725 -fno-plt -pipe -fPIC"
CXXFLAGS="-Wno-error -Wno-error=implicit-function-declaration -O3 -mcpu=cortex-a725 -fno-plt -pipe -fPIC"

# Set host and build aliases based on ndk_triple
export host_alias=$ndk_triple
export build_alias=x86_64-pc-linux-gnu

# Add additional flags to handle Android-specific issues
# Disable functions that are not available on Android
export ac_cv_func_canonicalize_file_name=no
export ac_cv_func_error=no
export ac_cv_func_fnmatch_gnu=no
export ac_cv_func_getcwd=no
export ac_cv_func_getcwd_null=no
export ac_cv_func_getegid32=no
export ac_cv_func_geteuid32=no
export ac_cv_func_getgid32=no
export ac_cv_func_getgroups32=no
export ac_cv_func_getpwuid_r=no
export ac_cv_func_getuid32=no
export ac_cv_func_lstat_dereferences_slashed_symlink=no
export ac_cv_func_mbrtowc=no
export ac_cv_func_readlink=no
export ac_cv_func_setlocale=no
export ac_cv_func_stat_time=no
export ac_cv_func_tzset=no
export ac_cv_func_unsetenv=no
export ac_cv_func_wctomb=no
export ac_cv_func_writev=no

CPPFLAGS="-I.."

../configure \
    --enable-shared \
    --enable-static \
    --with-minimum \
    --with-threads=no \
    --with-tree \
    --without-lzma \
    --host=$host_alias \
    --disable-rpath \
    --disable-symlink \
    --disable-external-libiconv

echo -e "\n-----------------\nconfig.log start\n-----------------\n"
find ../ -name "config.log" -exec cat {} \;
echo -e "\n-----------------\nconfig.log end\n-----------------\n"

make -j$cores
make DESTDIR="$prefix_dir" install