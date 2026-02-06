#!/bin/bash -e

## Dependency versions

v_sdk=11076708_latest
v_ndk=29.0.14206865
v_sdk_build_tools=35.0.0

v_libass=0.17.4
v_harfbuzz=12.2.0
v_fribidi=1.0.16
v_freetype=2-14-1
v_mbedtls=4.0.0
v_dav1d=1.5.2
v_libxml2=2.15.1
v_libiconv=1.18
v_ffmpeg=8.0.1
v_mpv=41f6a645068483470267271e1d09966ca3b9f413
v_libogg=1.3.6
v_libvorbis=1.3.7
v_libvpx=1.15
v_libplacebo=6.338.2


## Dependency tree
# I would've used a dict but putting arrays in a dict is not a thing

dep_mbedtls=()
dep_dav1d=()
dep_libxml2=(libiconv)
dep_libvorbis=(libogg)

if [ -n "${ENCODERS_GPL+x}" ]; then
	dep_ffmpeg=(mbedtls dav1d libxml2 libvorbis libvpx libx264)

else
	dep_ffmpeg=(mbedtls dav1d libxml2)
fi
dep_freetype2=()
dep_fribidi=()
dep_harfbuzz=()
dep_libass=(freetype fribidi harfbuzz)
dep_lua=()
dep_shaderc=()

if [ -n "${ENCODERS_GPL+x}" ]; then
	dep_mpv=(ffmpeg libass fftools_ffi)
else
	dep_mpv=(ffmpeg libass libplacebo lua)
fi
