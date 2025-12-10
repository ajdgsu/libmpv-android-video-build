#!/bin/bash -e


. ../../include/depinfo.sh
. ../../include/path.sh


# Define a build directory for out-of-source builds, which is a CMake best practice.
build_dir="build"


if [ "$1" == "build" ]; then
    # The build process now involves cleaning, configuring with CMake, and then building.
    true
elif [ "$1" == "clean" ]; then
    # For CMake, cleaning is simply removing the build directory.
    echo "Cleaning build directory: $build_dir"
    rm -rf "$build_dir"
    exit 0
else
    exit 255
fi


# 1. Clean previous build artifacts to ensure a fresh start.
# This mirrors the original script's behavior of always cleaning before building.
echo "Starting a clean build..."
$0 clean


# 2. Create the build directory and enter it.
mkdir -p "$build_dir"
cd "$build_dir"


# 3. Configure the project with CMake.
#    - .. : Points to the source directory (the parent directory).
#    -DENABLE_TESTING=OFF : This is the CMake equivalent of the old 'no_test' make target.
#                          It builds the library and programs but skips the test suites.
echo "Configuring with CMake..."
cmake -DENABLE_TESTING=OFF -DCMAKE_BUILD_TYPE=Release ..


# 4. Build the project and install it.
#    - cmake --build . : The modern, generator-agnostic way to build a CMake project.
#    - --target install : Specifies that we want to run the 'install' target.
#    - --parallel $cores : The equivalent of 'make -j$cores'.
#    - -- : Separates CMake options from options passed to the underlying build tool (like make).
#    - DESTDIR="$prefix_dir" : The installation prefix, passed to the underlying tool.
echo "Building and installing..."
cmake --build . --target install --parallel "$cores" -- DESTDIR="$prefix_dir"


echo "Mbed TLS build and installation complete."
