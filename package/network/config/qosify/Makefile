#
# Copyright (C) 2021 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk
include $(INCLUDE_DIR)/kernel.mk

PKG_NAME:=qosify
PKG_SOURCE_URL=https://github.com/liudf0716/chaqos.git
PKG_SOURCE_PROTO:=git
PKG_SOURCE_DATE:=2024-08-07
PKG_SOURCE_VERSION:=fd914ee7cff7b36056c5f54328a87da2b0b56f92
PKG_MIRROR_HASH:=6ba1f4db87862bc866a6c551a2f5d0ae976c90fc620c10d6e2f0371412d0eef0
PKG_RELEASE:=1

PKG_LICENSE:=GPL-2.0
PKG_MAINTAINER:=Felix Fietkau <nbd@nbd.name>

PKG_BUILD_DEPENDS:=bpf-headers
PKG_FLAGS:=nonshared

include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/cmake.mk
include $(INCLUDE_DIR)/bpf.mk
include $(INCLUDE_DIR)/nls.mk

define Package/qosify
  SECTION:=utils
  CATEGORY:=Base system
  TITLE:=A simple QoS solution based eBPF + CAKE
  DEPENDS:=+libbpf +libubox +libubus +libnl-tiny +kmod-sched-cake +kmod-sched-bpf +kmod-ifb +tc $(BPF_DEPENDS)
endef

TARGET_CFLAGS += \
	-Wno-error=deprecated-declarations \
	-I$(STAGING_DIR)/usr/include/libnl-tiny \
	-I$(STAGING_DIR)/usr/include

CMAKE_OPTIONS += \
	-DLIBNL_LIBS=-lnl-tiny

define Build/Compile
	$(call CompileBPF,$(PKG_BUILD_DIR)/qosify-bpf.c)
	$(Build/Compile/Default)
endef

define Package/qosify/conffiles
/etc/config/qosify
/etc/qosify/00-defaults.conf
endef

define Package/qosify/install
	$(INSTALL_DIR) \
		$(1)/lib/bpf \
		$(1)/usr/sbin \
		$(1)/etc/init.d \
		$(1)/etc/config \
		$(1)/etc/qosify \
		$(1)/etc/hotplug.d/net \
		$(1)/etc/hotplug.d/iface
	$(INSTALL_DATA) $(PKG_BUILD_DIR)/qosify-bpf.o $(1)/lib/bpf
	$(INSTALL_BIN) \
		$(PKG_INSTALL_DIR)/usr/bin/qosify \
		./files/qosify-status \
		$(1)/usr/sbin/
	$(INSTALL_BIN) ./files/qosify.init $(1)/etc/init.d/qosify
	$(INSTALL_DATA) ./files/qosify-defaults.conf $(1)/etc/qosify/00-defaults.conf
	$(INSTALL_DATA) ./files/qosify.conf $(1)/etc/config/qosify
	$(INSTALL_DATA) ./files/qosify.hotplug $(1)/etc/hotplug.d/net/10-qosify
	$(INSTALL_DATA) ./files/qosify.hotplug $(1)/etc/hotplug.d/iface/10-qosify
endef

$(eval $(call BuildPackage,qosify))
