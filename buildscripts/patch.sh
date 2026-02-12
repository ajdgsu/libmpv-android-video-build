#!/bin/bash -e

PATCHES=(patches/*)
ROOT=$(pwd)

for dep_path in "${PATCHES[@]}"; do
    if [ -d "$dep_path" ]; then
        dep=$(echo $dep_path |cut -d/ -f 2)
        cd deps/$dep
        echo Patching $dep
        git reset --hard
        # Check if there are any patch files
        shopt -s nullglob
        patches=("$ROOT/$dep_path"/*.patch)
        shopt -u nullglob
        if [ ${#patches[@]} -gt 0 ]; then
            for patch in "${patches[@]}"; do
                if [ -f "$patch" ]; then
                    echo Applying $patch
                    git apply "$patch"
                fi
            done
        fi
        cd $ROOT
    fi
done

exit 0
