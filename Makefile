# See /LICENSE for more information.
# This is free software, licensed under the GNU General Public License v3.
# Copyright (C) 2024 rtaserver

include $(TOPDIR)/rules.mk

PKG_MAINTAINER:=rtaserver <https://github.com/rtaserver/luci-app-rakitiw>
PKG_NAME:=luci-app-rakitiw
PKG_VERSION:=1.1.8

PKG_BUILD_DIR:=$(BUILD_DIR)/$(PKG_NAME)

define Package/$(PKG_NAME)
	CATEGORY:=LuCI
	SUBMENU:=3. Applications
	TITLE:=LuCI support for rakitan
	PKGARCH:=all
	DEPENDS:=
endef

define Package/$(PKG_NAME)/description
    A LuCI support for rakitan
endef

include $(INCLUDE_DIR)/package.mk

define Build/Prepare
	mkdir -p $(PKG_BUILD_DIR)
	$(CP) $(CURDIR)/root $(PKG_BUILD_DIR)
	$(CP) $(CURDIR)/luasrc $(PKG_BUILD_DIR)
	chmod 0755 $(PKG_BUILD_DIR)/root/etc/init.d/rakitiw
	chmod 0755 $(PKG_BUILD_DIR)/root/usr/bin/modemngentod.sh
	chmod 0755 $(PKG_BUILD_DIR)/root/etc/uci-defaults/99_rakitiw
endef

define Build/Configure
endef

define Build/Compile
endef

define Package/$(PKG_NAME)/preinst
#!/bin/sh
if [ -f "/etc/config/rakitiw" ]; then
	/usr/bin/modemngentod.sh -k
fi
exit 0
endef

define Package/$(PKG_NAME)/postinst

endef

define Package/$(PKG_NAME)/prerm
#!/bin/sh
/usr/bin/modemngentod.sh -k
exit 0
endef

define Package/$(PKG_NAME)/postrm

endef

define Package/$(PKG_NAME)/install
	$(INSTALL_DIR) $(1)/usr/lib/lua/luci
	$(INSTALL_DIR) $(1)/www/rakitiw
	$(CP) $(PKG_BUILD_DIR)/root/* $(1)/
	$(CP) $(PKG_BUILD_DIR)/luasrc/* $(1)/usr/lib/lua/luci/
	$(CP) $(PKG_BUILD_DIR)/www/* $(1)/www/
endef

$(eval $(call BuildPackage,$(PKG_NAME)))