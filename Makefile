# See /LICENSE for more information.
# This is free software, licensed under the GNU General Public License v3.
# Copyright (C) 2024 rtaserver

include $(TOPDIR)/rules.mk

PKG_MAINTAINER:=rtaserver <https://github.com/rtaserver/luci-app-rakitiw>
PKG_NAME:=luci-app-rakitiw
PKG_VERSION:=1.1.8
PKG_DEPENDS:=+bash
LUCI_TITLE:=LuCI support for Rakitan

PKG_BUILD_DIR:=$(BUILD_DIR)/$(PKG_NAME)

include $(INCLUDE_DIR)/package.mk

define Build/Prepare
	mkdir -p $(PKG_BUILD_DIR)
	$(CP) $(CURDIR)/root $(PKG_BUILD_DIR)
	$(CP) $(CURDIR)/luasrc $(PKG_BUILD_DIR)
	chmod 0755 $(PKG_BUILD_DIR)/root/etc/init.d/rakitiw
	chmod 0755 $(PKG_BUILD_DIR)/root/usr/bin/modemngentod.sh
	chmod 0755 $(PKG_BUILD_DIR)/root/etc/uci-defaults/99_rakitiw
endef

define Package/$(PKG_NAME)/preinst
#!/bin/sh
	if [ -f "/etc/config/rakitiw" ]; then
		/usr/bin/rakitiw -k
		cp -f "/etc/config/rakitiw" "/tmp/rakitiw/rakitiw.bak"
		rm -rf /www/rakitiw/ >/dev/null 2>&1
	fi
	exit 0
endef

define Package/$(PKG_NAME)/postinst
#!/bin/sh
	if [ -f "/tmp/rakitiw/rakitiw.bak" ]; then
		chmod 0755 /usr/bin/modemngentod.sh
	fi
	exit 0
endef

define Package/$(PKG_NAME)/prerm
#!/bin/sh
	/usr/bin/modemngentod.sh -k
	cp -f "/etc/config/rakitiw" "/tmp/rakitiw/rakitiw.bak"
	exit 0
endef

define Package/$(PKG_NAME)/postrm
#!/bin/sh
	rm -rf /etc/config/rakitiw >/dev/null 2>&1
	rm -rf /www/rakitiw/ >/dev/null 2>&1
	exit 0
endef

define Package/$(PKG_NAME)/install
	$(INSTALL_DIR) $(1)/usr/lib/lua/luci
	$(INSTALL_DIR) $(1)/www/rakitiw
	$(CP) $(PKG_BUILD_DIR)/root/* $(1)/
	$(CP) $(PKG_BUILD_DIR)/luasrc/* $(1)/usr/lib/lua/luci/
	$(CP) $(PKG_BUILD_DIR)/www/* $(1)/www/
endef

$(eval $(call BuildPackage,$(PKG_NAME)))
