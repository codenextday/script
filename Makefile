# Makefile for qchip project
# PROJ_DIR := $(shell pwd)
OUTPUT_DIR := ${PROJ_DIR}/target
UBOOT_OUT_DIR := $(OUTPUT_DIR)/U-BOOT
KERN_OUT_DIR := $(OUTPUT_DIR)/KERNEL
ATF_OUT_DIR := $(OUTPUT_DIR)/ATF

FIP_OFFSET := 0x30040

AARCH64_TOOLCHAIN := $(TOOLCHAINS_DIR)/aarch64-linux-gnu/bin
AARCH64_ELF_TOOLCHAIN := $(TOOLCHAINS_DIR)/aarch64-elf/bin
$(OUTPUT_DIR):
	@echo OUTPUT_DIR:$(OUTPUT_DIR)
	mkdir ${OUTPUT_DIR}

$(UBOOT_OUT_DIR): $(OUTPUT_DIR)
	@-mkdir $(UBOOT_OUT_DIR)

$(KERN_OUT_DIR): $(OUTPUT_DIR)
	@-mkdir $(KERN_OUT_DIR)

$(ATF_OUT_DIR): $(OUTPUT_DIR)
	@-mkdir $(ATF_OUT_DIR)

$(OUT_BASE):
	@mkdir ${PROJ_DIR}/target

prepare: $(OUT_BASE)
	@echo "base out dir make"

uboot: prepare $(UBOOT_OUT_DIR)
	@echo "build uboot"
	make ARCH=arm CROSS_COMPILE=$(AARCH64_TOOLCHAIN)/aarch64-linux-gnu-  -C u-boot/  O=$(UBOOT_OUT_DIR)  qserver_defconfig
	make ARCH=arm CROSS_COMPILE=$(AARCH64_TOOLCHAIN)/aarch64-linux-gnu- -C u-boot/  O=$(UBOOT_OUT_DIR) -j2

atf: prepare $(ATF_OUT_DIR)
	@echo "build arm trusted firmware for FPGA"
	rm -rf $(ATF_OUT_DIR)/qserver-mtd
	PLATFORM=qserver  CROSS_COMPILE=$(AARCH64_ELF_TOOLCHAIN)/aarch64-elf- make -C trusted-firmware-a/ DEBUG=0 USE_COHERENT_MEM=0 CTX_INCLUDE_AARCH32_REGS=0 HW_ASSISTED_COHERENCY=1 ERROR_DEPRECATED=1 LOAD_IMAGE_V2=1 BOOT_DEVICE=MTD BL33=$(UBOOT_OUT_DIR)/u-boot.bin PLAT=qserver BUILD_BASE=$(ATF_OUT_DIR)  SPD=opteed BL32=$(OUTPUT_DIR)/tee-pager.bin all fip  all
	mv $(ATF_OUT_DIR)/qserver $(ATF_OUT_DIR)/qserver-mtd
	@echo "build arm trusted firmware for VDK"
	PLATFORM=qserver  CROSS_COMPILE=$(AARCH64_ELF_TOOLCHAIN)/aarch64-elf- make -C trusted-firmware-a/ DEBUG=0 FIP_OFFSET=$(FIP_OFFSET) USE_COHERENT_MEM=0 CTX_INCLUDE_AARCH32_REGS=0 HW_ASSISTED_COHERENCY=1 ERROR_DEPRECATED=1 LOAD_IMAGE_V2=1 BL33=$(UBOOT_OUT_DIR)/u-boot.bin PLAT=qserver BUILD_BASE=$(ATF_OUT_DIR)  all fip  all
	cd -

kernel: prepare $(KERN_OUT_DIR)
	@echo "build kernel"
	make ARCH=arm64 CROSS_COMPILE=$(AARCH64_TOOLCHAIN)/aarch64-linux-gnu-  -C linux-stable-5.8/  O=$(KERN_OUT_DIR)  qserver_defconfig
	make ARCH=arm64 CROSS_COMPILE=$(AARCH64_TOOLCHAIN)/aarch64-linux-gnu- -C linux-stable-5.8/  O=$(KERN_OUT_DIR) -j4
	cd $(KERN_OUT_DIR) && ${PROJ_DIR}/linux-stable-5.8/usr/gen_initramfs.sh -o $(OUTPUT_DIR)/initramfs_data.cpio.gz  -u 0  -g 0  ${PROJ_DIR}/tools/rootfs
	cp $(KERN_OUT_DIR)/arch/arm64/boot/Image.gz $(OUTPUT_DIR)/
	cd $(OUTPUT_DIR) && ./mkimage -f multi.its uImage
bootloader:
#	cp $(ATF_OUT_DIR)/qserver-mtd/release/fip.bin $(ATF_OUT_DIR)/qserver/release/
	sh $(PROJ_DIR)/script/merge.sh --out-path=$(ATF_OUT_DIR)/qserver/release --fip-offset=$(FIP_OFFSET)
	mv $(ATF_OUT_DIR)/qserver/release/u-boot-merge.img $(OUTPUT_DIR)/bootloader
	cp $(UBOOT_OUT_DIR)/u-boot.dtb $(OUTPUT_DIR)/ 
	cp $(UBOOT_OUT_DIR)/tools/mkimage $(OUTPUT_DIR)/ 

