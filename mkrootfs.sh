#!/bin/sh
# build project for qchip
TEMP=`getopt  -o d:a: -l dir:,out:  -- "$@"`
eval set -- "$TEMP"
help()
{
	echo "./mkrootfs.sh --dir=<path/to/rootfs>"
}
while true
do
	case "$1" in
		-d|--dir)
			d=$2
			shift 2
			;;
		-o|--out)
			o=$2
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
echo ${d}
outdir=${d}/..
dd if=/dev/zero of=${outdir}/tmp.img bs=1G count=2
mkfs.ext4  ${outdir}/tmp.img
if [ ! -d ${outdir}/mnt ]; then
mkdir -p ${outdir}/mnt
fi

sudo mount -t ext4 ${outdir}/tmp.img ${outdir}/mnt
sudo cp -rf ${d}/* ${outdir}/mnt/
ls ${outdir}/mnt
sudo umount ${outdir}/mnt
mv ${outdir}/tmp.img ${o}
