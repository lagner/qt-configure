#!/bin/bash
. globals.sh

platform=${1:-"android"}
arch=${2:-"armeabi-v7a"} # wrong!

pushd_s $qt_src
branch=$(current_branch)
popd_s

dir_name="$platform-$branch"
if [ "$platform" == "android" ]; then
    dir_name="$platform-$arch-$branch"
fi
build_dir=$build_dir/$dir_name
install_dir=$install_dir/$dir_name

common="-prefix $install_dir $(get_array_value $conf_options_file $platform)"
if [ "$platform" == "android" ]; then
    common="$common \
        -xplatform android-clang\
        -android-ndk $ANDROID_NDK\
        -android-sdk $ANDROID_SDK\
        -android-arch $arch\
        -android-ndk-host linux-x86_64"
fi

skip_modules=(
    $(get_array_value $skip_modules_file $platform)
)

no_features=(
    $(get_array_value $no_features_file $platform)
)

modules=$(transform_prefix ' -skip ' ${skip_modules[@]})
features=$(transform_prefix ' -no-feature-' ${no_features[@]})
options="$common $modules $features"

if [ ! -d $build_dir ]; then
    mkdir -p $build_dir || exit 1
fi


pushd_s $build_dir

extra=""
if [ -n "$ssl_includes" ]; then
    extra="-I $ssl_includes"
fi

ssl=""
ssl_includes=""

if [ "$platform" == "android" ]; then
    ssl="-L$ssl_root/$arch/lib -lssl -lcrypto"
    ssl_includes="-I$ssl_headers"
fi

OPENSSL_LIBS="$ssl" $qt_src/configure $options $ssl_includes

popd_s
