# See /LICENSE for more information.
# This is free software, licensed under the GNU General Public License v3.
# Copyright (C) 2024 rtaserver

include $(TOPDIR)/rules.mk

PKG_MAINTAINER:=rtaserver <https://github.com/rtaserver/luci-app-rakitiw>
PKG_NAME:=luci-app-rakitiw
PKG_VERSION:=1.1.8
PKG_DEPENDS:=+bash
LUCI_TITLE:=LuCI support for Rakitan

include $(INCLUDE_DIR)/package.mk


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
chmod 0755 /usr/bin/modemngentod.sh
chmod 0755 /etc/init.d/rakitiw
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



$(eval $(call BuildPackage,$(PKG_NAME)))
