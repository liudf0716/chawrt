# SPDX-License-Identifier: GPL-2.0-only
#
# Copyright (C) 2024 Dengfeng Liu <liudf0716@gmail.com>

include $(TOPDIR)/rules.mk

# Package information
PKG_NAME:=default-settings
PKG_RELEASE:=5
PKG_LICENSE:=GPL-2.0-only

# Include OpenWrt package macros
include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/version.mk

# Package definition
define Package/default-settings
  SECTION:=luci
  CATEGORY:=LuCI
  TITLE:=LuCI support for Default Settings
  DEPENDS:=+luci \
          +@LUCI_LANG_zh_Hans \
          +luci-i18n-base-zh-cn \
          +luci-app-apfree-wifidog \
          +luci-app-xfrpc \
          +aw-bpf \
          +luci-theme-argon \
          +luci-app-clawwrt \
          +PACKAGE_strongswan:luci-app-strongswan-swanctl \
          +luci-proto-wireguard
  PKGARCH:=all
endef

# Skip compilation as there's nothing to compile
define Build/Compile
endef

# Installation
define Package/default-settings/install
	$(INSTALL_DIR) $(1)/etc
	$(INSTALL_DATA) ./files/banner $(1)/etc/banner.chawrt
	$(VERSION_SED_SCRIPT) $(1)/etc/banner.chawrt
	$(INSTALL_DIR) $(1)/etc/uci-defaults
	$(INSTALL_BIN) ./files/99-default-settings $(1)/etc/uci-defaults/
	$(INSTALL_BIN) ./files/80-in500-in500r-5g-settings $(1)/etc/uci-defaults/
	$(INSTALL_DIR) $(1)/etc/hotplug.d/iface
	$(INSTALL_BIN) ./files/60-hotplugd-iface-wan-wwan-switch $(1)/etc/hotplug.d/iface/
	$(INSTALL_BIN) ./files/70-hotplugd-iface-wan-lan-conflict $(1)/etc/hotplug.d/iface/
	$(INSTALL_BIN) ./files/71-hotplugd-iface-wwan-lan-conflict $(1)/etc/hotplug.d/iface/
	$(INSTALL_DIR) $(1)/etc/profile.d
	$(INSTALL_BIN) ./files/10-sysinfo-motd.sh $(1)/etc/profile.d/
endef

# Build package
$(eval $(call BuildPackage,default-settings))
