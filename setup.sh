#!/bin/sh
PROJ_DIR=`pwd`
TOOLCHAINS_DIR=$PROJ_DIR/prebuilts/gcc
if [ ! -d $TOOLCHAINS_DIR/aarch64-linux-gnu ];then
	echo "extract toolchains..."
	mkdir $TOOLCHAINS_DIR/aarch64-linux-gnu
	tar -xJf $TOOLCHAINS_DIR/x86_64_aarch64-linux-gnu.tar.xz  -C  $TOOLCHAINS_DIR/aarch64-linux-gnu --strip-components 1
fi
if [ ! -d $TOOLCHAINS_DIR/aarch64-elf ];then
	echo "extract toolchains..."
	mkdir $TOOLCHAINS_DIR/aarch64-elf
	tar -xJf $TOOLCHAINS_DIR/x86_64_aarch64-elf.tar.xz  -C  $TOOLCHAINS_DIR/aarch64-elf --strip-components 1
fi
export PROJ_DIR=$PROJ_DIR
export TOOLCHAINS_DIR=$TOOLCHAINS_DIR
