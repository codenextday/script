#!/bin/sh
# merge images to bootloader
TEMP=`getopt  -o  -a -l out-path:,fip-offset: -- "$@"`
eval set -- "$TEMP"

echo $1
while true
do
	case "$1" in
		--out-path)
			OUT_PATH=$2
			echo $OUT_PATH
			shift 2
			;;
		--fip-offset)
			FIP_OFFSET=$2
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
FIP_OFFSET=$(($FIP_OFFSET))
size=`ls -l $OUT_PATH/bl1.bin | awk '{print $5}'`
zero_size=`expr $FIP_OFFSET - $size`
#echo $zero_size
dd if=/dev/zero of=$OUT_PATH/bl1-zero.img bs=1 count=$zero_size
cat $OUT_PATH/bl1.bin $OUT_PATH/bl1-zero.img $OUT_PATH/fip.bin > $OUT_PATH/u-boot-merge.img
