#!/bin/bash

sd="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

qt_src=$sd/qt-src

build_dir=$(realpath "$sd/build")
install_dir="$HOME/Qt"
patches_dir="$sd/patches"
configuration_dir="$sd/configuration"

conf_options_file='options.txt'
skip_modules_file='skip_modules.txt'
no_features_file='no_features.txt'

# OpenSSL
ssl_root=$sd"/openssl/openssl-1.0.2"
ssl_headers=${ssl_root}"/include"


pushd_s() {
    pushd "$@" &>/dev/null
}

popd_s() {
    popd &>/dev/null
}

get_submodules() {
    pushd $1 &>/dev/null
    git config --file .gitmodules --get-regexp path | awk '{ print $2 }' | sort
    popd &>/dev/null
}

transform_prefix() {
    local separator="$1"
    local result=""
    shift
    for s in "$@"; do
        result="$result$separator$s"
    done
    echo $result
}

current_branch() {
    git branch | grep \* | cut -d ' ' -f2
}

commits_since() {
    git rev-list ${1}^..HEAD
}

confirm() {
    read -p "$1" -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        return 1
    fi
}

echo_red() {
    printf "\033[31;4m$1\033[0m\n"
}

match_patterns() {
    local reference=${1-?"reference word was not difined"}
    shift
    for pattern in "$@"; do
        if [[ "$reference" =~ "$pattern" ]]; then
            return 0
        fi
    done
    return 1
}

get_array_value() {
    local filename=${1:?'need file name'}
    local profile=${2:?'need profile name'}

    pushd_s $configuration_dir

    declare -a lines
    readarray lines < $filename

    if [ -f $profile/$filename ]; then
        declare -a extra
        readarray extra < $profile/$filename
        lines+=("${extra[@]}")
    fi

    popd_s
    echo ${lines[@]}
}


qt_submodules_all=($(get_submodules $qt_src))

declare -A qt_submodules_set=(
    ['qtandroidextras']=1
    ['qtbase']=1
    ['qtdeclarative']=1
    ['qtgraphicaleffects']=1
    ['qtimageformats']=1
    ['qtlocation']=1
    ['qtmultimedia']=1
    ['qtquickcontrols']=1
    ['qtquickcontrols2']=1
    ['qtsensors']=1
    ['qtsvg']=1
    ['qttools']=1
    ['qtwebsockets']=1
)

qt_submodules=("${!qt_submodules_set[@]}")
qt_submodules_extra=()

for s in "${qt_submodules_all[@]}"; do
    if [ -z "${qt_submodules_set[$s]}" ]; then
        qt_submodules_extra+=("$s")
    fi
done
