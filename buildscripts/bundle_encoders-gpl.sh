#!/bin/bash -e

# --------------------------------------------------
set -euxo pipefail

if [ -d "deps" ]; then
  sudo rm -r deps
fi
if [ -d "prefix" ]; then
  sudo rm -r prefix
fi

export ENCODERS_GPL=1

./download.sh
./patch.sh
./patch-encoders-gpl.sh

# --------------------------------------------------

if [ -f "scripts/ffmpeg" ]; then
  rm scripts/ffmpeg.sh
fi
cp flavors/encoders-gpl.sh scripts/ffmpeg.sh

# --------------------------------------------------

./build.sh --arch arm64

zip -r debug-symbols-encoders-gpl.zip prefix/arm64-v8a/lib

. ./include/depinfo.sh
./sdk/android-sdk-linux/ndk/$v_ndk/toolchains/llvm/prebuilt/linux-x86_64/bin/llvm-strip --strip-all prefix/arm64-v8a/usr/local/lib/libmpv.so

# --------------------------------------------------

cd deps/media-kit-android-helper

sudo chmod +x gradlew
./gradlew assembleRelease

unzip -o app/build/outputs/apk/release/app-release.apk -d app/build/outputs/apk/release

cp ../../prefix/arm64-v8a/usr/local/lib/libmpv.so      app/build/outputs/apk/release/lib/arm64-v8a

cd app/build/outputs/apk/release

zip -r encoders-gpl-arm64-v8a.jar      lib/arm64-v8a/*.so

md5sum *.jar

cd ../../../../../../..

mkdir -p artifacts/encoders-gpl
cp deps/media-kit-android-helper/app/build/outputs/apk/release/encoders-gpl-*.jar artifacts/encoders-gpl/
