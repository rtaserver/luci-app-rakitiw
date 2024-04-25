# See /LICENSE for more information.
# This is free software, licensed under the GNU General Public License v3.
# Copyright (C) 2024 rtaserver

include $(TOPDIR)/rules.mk

LUCI_TITLE:=Auto Reconnect Modem Rakitan
PKG_NAME:=luci-app-rakitiw
LUCI_DEPENDS:=+modemmanager +python3-pip +jq +adb
PKG_VERSION:=1.3.0
PKG_LICENSE:=Apache-2.0
PKG_MAINTAINER:=Rizki Kotet <rizkidhc31@gmail.com>

define Package/$(PKG_NAME)
  $(call Package/luci/webtemplate)
  TITLE:=$(LUCI_TITLE)
  DEPENDS:=$(LUCI_DEPENDS)
endef

define Package/$(PKG_NAME)/description
  LuCI version of Rakitiw, with some mods and additions for modem rakitan.
endef

include $(INCLUDE_DIR)/package.mk

define Build/Prepare
	mkdir -p $(PKG_BUILD_DIR)
	$(CP) $(CURDIR)/root $(PKG_BUILD_DIR)
	$(CP) $(CURDIR)/luasrc $(PKG_BUILD_DIR)
	$(CP) $(CURDIR)/htdocs $(PKG_BUILD_DIR)
	chmod 0755 $(PKG_BUILD_DIR)/root/etc/init.d/rakitiw
	chmod 0755 $(PKG_BUILD_DIR)/root/usr/bin/rakitanmanager.sh
  	chmod 0755 $(PKG_BUILD_DIR)/root/usr/bin/modem-orbit.py
	chmod 0755 $(PKG_BUILD_DIR)/root/etc/uci-defaults/99_rakitiw
endef

define Build/Configure
endef

define Build/Compile
endef

define Package/$(PKG_NAME)/preinst
#!/bin/sh
	if [ -f "/www/rakitiw/data_modem.json" ]; then

		cp -f "/www/rakitiw/data_modem.json" "/tmp/rakitiw/data_modem.bak"

		rm -rf /www/rakitiw/ >/dev/null 2>&1
	fi
	exit 0
endef

define Package/$(PKG_NAME)/postinst
#!/bin/sh
	if [ -f "/tmp/rakitiw/data_modem.bak" ]; then
		cp -rf "/tmp/rakitiw/data_modem.bak" "/www/rakitiw/data_modem.json"
    	chmod 0755 /usr/bin/rakitanmanager.sh
    	chmod 0755 /usr/bin/modem-orbit.py
		chmod 0755 /etc/init.d/rakitiw
	fi
	exit 0
endef

define Package/$(PKG_NAME)/prerm
#!/bin/sh
	/usr/bin/rakitanmanager -k

	cp -f "/www/rakitiw/data_modem.json" "/tmp/rakitiw/data_modem.bak"
	exit 0
endef

define Package/$(PKG_NAME)/postrm
#!/bin/sh
	rm -rf /etc/rakitiw/ >/dev/null 2>&1
	rm -rf /www/rakitiw/ >/dev/null 2>&1
	exit 0
endef

define Package/$(PKG_NAME)/install
	$(INSTALL_DIR) $(1)/usr/lib/lua/luci
	$(INSTALL_DIR) $(1)/www/rakitiw
	$(CP) $(PKG_BUILD_DIR)/root/* $(1)/
	$(CP) $(PKG_BUILD_DIR)/luasrc/* $(1)/usr/lib/lua/luci/
	$(CP) $(PKG_BUILD_DIR)/htdocs/* $(1)/www/
endef

include $(TOPDIR)/feeds/luci/luci.mk

$(eval $(call BuildPackage,$(PKG_NAME)))