# SPDX-License-Identifier: GPL-2.0-only

include $(TOPDIR)/rules.mk
include $(INCLUDE_DIR)/image.mk

DEVICE_VARS += UBOOT_DEVICE_NAME RK_PARTITION_LAYOUT

define Build/Compile
	$(CP) $(LINUX_DIR)/COPYING $(KDIR)/COPYING.linux
endef

### Image scripts ###
define Build/boot-common
	# This creates a new folder copies the dtb (as rockchip.dtb) 
	# and the kernel image (as kernel.img)
	rm -fR $@.boot
	mkdir -p $@.boot

	$(CP) $(IMAGE_KERNEL) $@.boot/kernel.img
endef

define Build/boot-ok3588
	# Create OK3588-specific FIT image matching factory U-Boot expectations
	# Factory U-Boot expects: config="conf", kernel="kernel", fdt="fdt"
	rm -fR $@.boot
	mkdir -p $@.boot

	# Extract kernel and DTB from IMAGE_KERNEL (FIT image)
	# Or use raw kernel image if available
	if [ -f "$(KDIR)/Image" ]; then \
		$(CURDIR)/mkits-ok3588.sh \
			"$(KDIR)/Image" \
			"$(DTS_DIR)/rockchip/rk3588-forlinx-ok3588.dtb" \
			"$@.boot/kernel.img" \
			"$(LINUX_VERSION)"; \
	else \
		echo "Warning: Using default kernel.img"; \
		$(CP) $(IMAGE_KERNEL) $@.boot/kernel.img; \
	fi
endef

define Build/boot-script
	# Make an U-boot image and copy it to the boot partition
	mkimage -A arm -O linux -T script -C none -a 0 -e 0 -d $(if $(1),$(1),default).bootscript $@.boot/boot.scr
endef

define Build/pine64-img
	# Creates the final SD/eMMC images, 
	# combining boot partition, root partition as well as the u-boot bootloader

	# Generate a new partition table in $@ with 32 MiB of 
	# alignment padding for the u-boot-rockchip.bin (idbloader + u-boot) to fit:
	# http://opensource.rock-chips.com/wiki_Boot_option#Boot_flow
	#
	# U-Boot SPL expects the U-Boot ITB to be located at sector 0x4000 (8 MiB) on the MMC storage
	PADDING=1 $(SCRIPT_DIR)/gen_image_generic.sh \
		$@ \
		$(CONFIG_TARGET_KERNEL_PARTSIZE) $@.boot \
		$(CONFIG_TARGET_ROOTFS_PARTSIZE) $(IMAGE_ROOTFS) \
		32768

	# Copy the u-boot-rockchip.bin to the image at sector 0x40 (if exists)
	[ -f "$(STAGING_DIR_IMAGE)/$(UBOOT_DEVICE_NAME)-u-boot-rockchip.bin" ] && \
		dd if="$(STAGING_DIR_IMAGE)"/$(UBOOT_DEVICE_NAME)-u-boot-rockchip.bin of="$@" seek=64 conv=notrunc || \
		echo "Warning: U-Boot file not found, skipping U-Boot embedding"
endef

define Build/rk-partition-img
	# Creates Rockchip standard partition layout image
	# Compatible with Rockchip parameter.txt and official tools
	# Uses original factory U-Boot binaries for compatibility
	
	rm -rf $@.rkimg
	mkdir -p $@.rkimg
	
	# Copy boot image (kernel FIT image)
	$(CP) $@.boot/kernel.img $@.rkimg/boot.img
	
	# Copy rootfs image
	$(CP) $(IMAGE_ROOTFS) $@.rkimg/rootfs.img
	
	# Copy original factory U-Boot if available (CRITICAL for OK3588)
	# OK3588 uses closed-source U-Boot, must use factory binary
	if [ -f "$(STAGING_DIR_IMAGE)/ok3588-uboot.img" ]; then \
		$(CP) "$(STAGING_DIR_IMAGE)/ok3588-uboot.img" $@.rkimg/uboot.img; \
		echo "Using factory U-Boot from staging"; \
	elif [ -f "$(CURDIR)/ok3588-uboot.img" ]; then \
		$(CP) "$(CURDIR)/ok3588-uboot.img" $@.rkimg/uboot.img; \
		echo "Using factory U-Boot from image dir"; \
	else \
		echo "WARNING: Factory U-Boot not found!"; \
		echo "Please copy original uboot.img to $(CURDIR)/ok3588-uboot.img"; \
		dd if=/dev/zero of=$@.rkimg/uboot.img bs=1M count=4; \
	fi
	
	# Copy MiniLoader (bootloader) - REQUIRED for rkImageMaker
	if [ -f "$(STAGING_DIR_IMAGE)/ok3588-miniloader.bin" ]; then \
		$(CP) "$(STAGING_DIR_IMAGE)/ok3588-miniloader.bin" $@.rkimg/MiniLoaderAll.bin; \
		echo "Using MiniLoader from staging"; \
	elif [ -f "$(CURDIR)/ok3588-miniloader.bin" ]; then \
		$(CP) "$(CURDIR)/ok3588-miniloader.bin" $@.rkimg/MiniLoaderAll.bin; \
		echo "Using MiniLoader from image dir"; \
	else \
		echo "WARNING: MiniLoader not found!"; \
		echo "rkImageMaker will be skipped"; \
	fi
	
	# Create minimal misc partition (8MB)
	dd if=/dev/zero of=$@.rkimg/misc.img bs=1M count=8
	
	# Create recovery partition (128MB) - CRITICAL for device recovery
	# Recovery partition is essential for unbrick functionality
	# Priority: Factory recovery (TF card auto-upgrade) > OpenWrt initramfs
	# 
	# Factory recovery provides:
	#   - TF card auto-upgrade (auto-detect and flash firmware)
	#   - User-friendly recovery experience
	#   - Compatible with factory tools
	#
	# Note: Factory recovery uses kernel 5.10, may have limited compatibility
	#       with OpenWrt 6.6 system for advanced operations
	if [ -f "$(STAGING_DIR_IMAGE)/ok3588-recovery.img" ]; then \
		$(CP) "$(STAGING_DIR_IMAGE)/ok3588-recovery.img" $@.rkimg/recovery.img; \
		echo "Using factory recovery (TF card auto-upgrade supported)"; \
	elif [ -f "$(CURDIR)/ok3588-recovery.img" ]; then \
		$(CP) "$(CURDIR)/ok3588-recovery.img" $@.rkimg/recovery.img; \
		echo "Using factory recovery (TF card auto-upgrade supported)"; \
	elif [ -f "$(KDIR)/vmlinux-initramfs.elf" ] || [ -f "$(KDIR)/Image-initramfs" ]; then \
		echo "Using OpenWrt-based recovery (advanced maintenance)"; \
		echo "NOTE: TF card auto-upgrade not available in OpenWrt recovery"; \
		if [ -f "$(KDIR)/Image-initramfs" ]; then \
			$(CP) "$(KDIR)/Image-initramfs" $@.rkimg/recovery-kernel; \
		else \
			$(CP) "$(KDIR)/vmlinux-initramfs.elf" $@.rkimg/recovery-kernel; \
		fi; \
		mkimage -A arm64 -O linux -T kernel -C none \
			-a 0x02080000 -e 0x02080000 -n "OpenWrt Recovery" \
			-d $@.rkimg/recovery-kernel $@.rkimg/recovery.img || \
			dd if=/dev/zero of=$@.rkimg/recovery.img bs=1M count=64; \
	else \
		echo "WARNING: No recovery available, creating placeholder"; \
		echo "Run ./prepare-ok3588-firmware.sh to get factory recovery"; \
		dd if=/dev/zero of=$@.rkimg/recovery.img bs=1M count=64; \
	fi
	
	# Create minimal backup partition (32MB) 
	dd if=/dev/zero of=$@.rkimg/backup.img bs=1M count=32
	
	# Create OEM partition (128MB) - for vendor customization
	if [ -f "$(STAGING_DIR_IMAGE)/ok3588-oem.img" ]; then \
		$(CP) "$(STAGING_DIR_IMAGE)/ok3588-oem.img" $@.rkimg/oem.img; \
	elif [ -f "$(CURDIR)/ok3588-oem.img" ]; then \
		$(CP) "$(CURDIR)/ok3588-oem.img" $@.rkimg/oem.img; \
	else \
		dd if=/dev/zero of=$@.rkimg/oem.img bs=1M count=128; \
	fi
	
	# Create empty userdata partition (32MB, will grow)
	dd if=/dev/zero of=$@.rkimg/userdata.img bs=1M count=32
	
	# Copy parameter file
	$(CP) $(CURDIR)/$(if $(1),$(1),parameter-$(DEVICE_NAME)).txt $@.rkimg/parameter.txt 2>/dev/null || \
		$(CP) $(CURDIR)/parameter-ok3588.txt $@.rkimg/parameter.txt
	
	# Pack into Rockchip update image with rkImageMaker
	# This creates a standard Rockchip update.img compatible with official tools
	$(CURDIR)/mk-rk-image.sh $@.rkimg $@.rkimg/parameter.txt $@ $@.rkimg/MiniLoaderAll.bin || \
		(echo "Warning: RK image packing failed, creating GPT image instead" && \
		 PADDING=1 $(SCRIPT_DIR)/gen_image_generic.sh $@ \
		 $(CONFIG_TARGET_KERNEL_PARTSIZE) $@.boot \
		 $(CONFIG_TARGET_ROOTFS_PARTSIZE) $(IMAGE_ROOTFS) 32768)
	
	rm -rf $@.rkimg
endef

### Devices ###
define Device/Default
  PROFILES := Default
  KERNEL = kernel-bin | lzma | fit lzma $$(DTS_DIR)/$$(DEVICE_DTS).dtb
  BOOT_SCRIPT :=
  IMAGES := sysupgrade.img.gz
  IMAGE/sysupgrade.img.gz = boot-common | boot-script $$(BOOT_SCRIPT) | pine64-img | gzip | append-metadata
  DEVICE_DTS = rockchip/$$(SOC)-$(lastword $(subst _, ,$(1)))
  UBOOT_DEVICE_NAME = $(lastword $(subst _, ,$(1)))-$$(SOC)
endef

include $(SUBTARGET).mk

$(eval $(call BuildImage))
