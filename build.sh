#!/bin/bash
# juergen@archlinux.org

set -e

NDK_DIR="${1}"
if [[ -z ${NDK_DIR} ]]; then
    echo "Usage $0 NDK_DIR" >&2
    exit 1
fi

TARGET=android-15
ARCH=${ARCH:=arch-arm}  # arch-x86, arch-arm
HOST=arm-eabi # arm-eabi
# armeabi-v7a,x86
TC_VER=4.8

if [[ $ARCH == *arm ]]; then
    tc_name=arm-linux-androideabi
else
    tc_name=x86
fi
tc_bin_prefix="${NDK_DIR}/toolchains/${tc_name}-${TC_VER}/prebuilt/linux-$(uname -m)/bin/"
CC=${tc_bin_prefix}*gcc

SYSROOT=$NDK_DIR/platforms/$TARGET/$ARCH
shift
CC="$CC  --sysroot=$SYSROOT" ./configure --host=$HOST --disable-utmp --disable-utmpx "$@"
sed -i 's/^\#define HAVE_STRUCT_UTMP_UT_TYPE 1/\#undef HAVE_STRUCT_UTMP_UT_TYPE/g' config.h
sed -i 's/^\#define ENABLE_CLI_PASSWORD_AUTH//g' options.h
make PROGRAMS="dbclient dropbearkey"
