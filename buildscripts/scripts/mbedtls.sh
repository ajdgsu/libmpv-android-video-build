#!/bin/bash -e

. ../../include/depinfo.sh
. ../../include/path.sh

if [ "$1" == "build" ]; then
	true
elif [ "$1" == "clean" ]; then
	make clean
	exit 0
else
	exit 255
fi

$0 clean # separate building not supported, always clean

make CFLAGS="-O3 -mcpu=cortex-a725 -fno-plt -pipe -fvectorize -funroll-loops -mllvm -polly -mllvm -polly-run-inliner -mllvm -polly-ast-use-context -mllvm -polly-detect-keep-going -mllvm -polly-invariant-load-hoisting -mllvm -polly-vectorizer=stripmine -mllvm -polly-loopfusion-greedy=1 -mllvm -polly-reschedule=1 -mllvm -polly-postopts=1 -mllvm -polly-run-dce -mllvm -hot-cold-split=true -flto=auto -fPIC" CXXFLAGS="-O3 -mcpu=cortex-a725 -fno-plt -pipe -fvectorize -funroll-loops -mllvm -polly -mllvm -polly-run-inliner -mllvm -polly-ast-use-context -mllvm -polly-detect-keep-going -mllvm -polly-invariant-load-hoisting -mllvm -polly-vectorizer=stripmine -mllvm -polly-loopfusion-greedy=1 -mllvm -polly-reschedule=1 -mllvm -polly-postopts=1 -mllvm -polly-run-dce -mllvm -hot-cold-split=true -flto=auto -fPIC" -j$cores no_test
make CFLAGS=-fPIC CXXFLAGS=-fPIC DESTDIR="$prefix_dir" install
