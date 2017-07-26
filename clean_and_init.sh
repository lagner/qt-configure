#!/bin/bash
. globals.sh


fetch=

while [[ $# -gt 1 ]]; do
    case $1 in
        -f|--fetch)
            fetch=true
            shift
        ;;
    esac
shift
done


clean() {
    git clean -xfd
    git reset --hard

    if [ "$fetch" = true ]; then
        git fetch --all --tags
    fi
}

pushd_s $qt_src

clean

for submodule in "${qt_submodules_extra[@]}"; do
    git submodule deinit -f $submodule
done

for submodule in "${qt_submodules[@]}"; do
    pushd_s $submodule
    clean
    popd_s

    git submodule update --init --checkout --recursive $submodule
done

popd_s
