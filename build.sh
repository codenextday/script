#!/bin/sh
# build project for qchip
TEMP=`getopt  -o  -a -l build-choice:  -- "$@"`
eval set -- "$TEMP"
#echo $1 $2

#PROJ_DIR=`pwd`
#OUTPUT_DIR=$PROJ_DIR/target

help()
{
	echo "./build.sh --build-choice=bootloader"
	echo "./build.sh --build-choice=kernel"
	echo "./build.sh --build-choice=distclean"
}
while true
do
	case "$1" in
		--build-choice)
			choice=$2
			shift 2
			;;

		--)
			shift;break;;
		*) 
			echo "Wrong parameter!"
			exit 1
			;;
	esac
done

case "$choice" in
	bootloader)
		BUILD_BOOTLOADER=1
		;;
	kernel)
		BUILD_KERNEL=1
		;;
	distclean)
		#BUILD_KERNEL=1
		rm -rf target
		;;
	*)
		help
		exit 1
		;;
esac

if [ "$BUILD_BOOTLOADER" = "1" ]; then
	make uboot
	make atf
	make bootloader
	#sh $(PROJ_DIR)/script/merge.sh --out-path=$(ATF_OUT_DIR)/qserver/release --fip-offset=131072
        #mv $(ATF_OUT_DIR)/qserver/release/u-boot-merge.img $(OUTPUT_DIR)/bootloader 
fi

if [ "$BUILD_KERNEL" = "1" ]; then
	make kernel
fi
