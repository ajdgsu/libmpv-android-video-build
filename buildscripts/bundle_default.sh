# --------------------------------------------------

export LDFLAGS="-Wl,-O1,--icf=safe -Wl,-z,max-page-size=16384 -Wl,--sort-common -Wl,--as-needed -Wl,-z,pack-relative-relocs"
	export CFLAGS="-O3 -mcpu=cortex-a725 -fno-plt -pipe -fvectorize -funroll-loops -mllvm -polly -mllvm -polly-run-inliner -mllvm -polly-ast-use-context -mllvm -polly-detect-keep-going -mllvm -polly-invariant-load-hoisting -mllvm -polly-vectorizer=stripmine -mllvm -polly-loopfusion-greedy=1 -mllvm -polly-reschedule=1 -mllvm -polly-postopts=1 -mllvm -polly-run-dce -mllvm -hot-cold-split=true -flto=auto"
	export CXXFLAGS="-O3 -mcpu=cortex-a725 -fno-plt -pipe -fvectorize -funroll-loops -mllvm -polly -mllvm -polly-run-inliner -mllvm -polly-ast-use-context -mllvm -polly-detect-keep-going -mllvm -polly-invariant-load-hoisting -mllvm -polly-vectorizer=stripmine -mllvm -polly-loopfusion-greedy=1 -mllvm -polly-reschedule=1 -mllvm -polly-postopts=1 -mllvm -polly-run-dce -mllvm -hot-cold-split=true -flto=auto"
	
if [ ! -f "deps" ]; then
  sudo rm -r deps
fi
if [ ! -f "prefix" ]; then
  sudo rm -r prefix
fi

./download.sh
./patch.sh

# --------------------------------------------------

if [ ! -f "scripts/ffmpeg" ]; then
  sudo rm scripts/ffmpeg.sh
fi
cp flavors/default.sh scripts/ffmpeg.sh

# --------------------------------------------------

./build.sh

zip -r debug-symbols-default.zip prefix/*/lib

./sdk/android-sdk-linux/ndk/27.3.13750724/toolchains/llvm/prebuilt/linux-x86_64/bin/llvm-strip --strip-all prefix/arm64-v8a/usr/local/lib/libmpv.so
./sdk/android-sdk-linux/ndk/27.3.13750724/toolchains/llvm/prebuilt/linux-x86_64/bin/llvm-strip --strip-all prefix/armeabi-v7a/usr/local/lib/libmpv.so
./sdk/android-sdk-linux/ndk/27.3.13750724/toolchains/llvm/prebuilt/linux-x86_64/bin/llvm-strip --strip-all prefix/x86/usr/local/lib/libmpv.so
./sdk/android-sdk-linux/ndk/27.3.13750724/toolchains/llvm/prebuilt/linux-x86_64/bin/llvm-strip --strip-all prefix/x86_64/usr/local/lib/libmpv.so

# --------------------------------------------------

cd deps/media-kit-android-helper

sudo chmod +x gradlew
./gradlew assembleRelease

unzip -o app/build/outputs/apk/release/app-release.apk -d app/build/outputs/apk/release

cp ../../prefix/arm64-v8a/usr/local/lib/libmpv.so      app/build/outputs/apk/release/lib/arm64-v8a
cp ../../prefix/armeabi-v7a/usr/local/lib/libmpv.so    app/build/outputs/apk/release/lib/armeabi-v7a
cp ../../prefix/x86/usr/local/lib/libmpv.so            app/build/outputs/apk/release/lib/x86
cp ../../prefix/x86_64/usr/local/lib/libmpv.so         app/build/outputs/apk/release/lib/x86_64

cd app/build/outputs/apk/release

zip -r default-arm64-v8a.jar      lib/arm64-v8a/*.so
zip -r default-armeabi-v7a.jar    lib/armeabi-v7a/*.so
zip -r default-x86.jar            lib/x86/*.so
zip -r default-x86_64.jar         lib/x86_64/*.so

md5sum *.jar

cd ../../../../../../..

mkdir -p artifacts/default
cp deps/media-kit-android-helper/app/build/outputs/apk/release/default-*.jar artifacts/default/
