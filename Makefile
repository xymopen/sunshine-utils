#
# Copyright (C) 2006-2015 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=sunshine-utils
PKG_VERSION:=3.0.2
PKG_RELEASE:=3
PKG_LICENSE:=BSD-2-Clause

PKG_MAINTAINER:=xymopen <xuyiming.open@outlook.com>

PKG_BUILD_DIR := $(BUILD_DIR)/$(PKG_NAME)

include $(INCLUDE_DIR)/package.mk

define Package/sunshine-utils
  SECTION:=net
  CATEGORY:=Network
  DEPENDS:=+coreutils-base64 +curl +jshn
  TITLE:=SUNSHINE utilities
  PKGARCH:=all
endef

define Package/sunshine-utils/description
  A set of functions used to interact with SUNSHINE - Internet Service Login
  which can found in Chinese colleges.
endef

define Package/sunshine-utils/conffiles
endef

define Build/Prepare
endef

define Build/Configure
endef

define Build/Compile
endef

define Package/sunshine-utils/install
	$(INSTALL_DIR) $(1)
	$(CP) ./files/* $(1)/
endef

$(eval $(call BuildPackage,sunshine-utils))
