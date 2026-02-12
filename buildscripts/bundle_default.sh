#!/bin/bash -e
set -euxo pipefail

if [ -d "deps" ]; then
  sudo rm -r deps
fi
if [ -d "prefix" ]; then
  sudo rm -r prefix
fi

./download.sh
./patch.sh

# --------------------------------------------------

if [ -f "scripts/ffmpeg" ]; then
  rm scripts/ffmpeg.sh
fi
cp flavors/default.sh scripts/ffmpeg.sh

# --------------------------------------------------

# Only build for arm64-v8a architecture
./build.sh --arch arm64

zip -q -r debug-symbols-default.zip prefix/arm64-v8a/lib

. ./include/depinfo.sh
./sdk/android-sdk-linux/ndk/$v_ndk/toolchains/llvm/prebuilt/linux-x86_64/bin/llvm-strip --strip-all prefix/arm64-v8a/usr/local/lib/libmpv.so

# --------------------------------------------------

cd deps/media-kit-android-helper

sudo chmod +x gradlew
./gradlew assembleRelease

unzip -q -o app/build/outputs/apk/release/app-release.apk -d app/build/outputs/apk/release

cp ../../prefix/arm64-v8a/usr/local/lib/libmpv.so      app/build/outputs/apk/release/lib/arm64-v8a

cd app/build/outputs/apk/release

zip -r default-arm64-v8a.jar      lib/arm64-v8a/*.so

md5sum *.jar

cd ../../../../../../..

mkdir -p artifacts/default
cp deps/media-kit-android-helper/app/build/outputs/apk/release/default-*.jar artifacts/default/
