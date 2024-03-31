# See /LICENSE for more information.
# This is free software, licensed under the GNU General Public License v3.
# Copyright (C) 2024 rtaserver

include $(TOPDIR)/rules.mk

PKG_MAINTAINER:=rtaserver <https://github.com/rtaserver/luci-app-rakitiw>
PKG_NAME:=luci-app-rakitiw
PKG_VERSION:=1.1.8
PKG_DEPENDS:=
LUCI_TITLE:=LuCI support for Rakitan

define Package/$(PKG_NAME)/postinst
#!/bin/sh
# cek jika ini adalah install atau upgrade
if [ "$${IPKG_INSTROOT}" = "" ]; then
    chmod -R 755 /usr/bin/modemngentod.sh
    chmod -R 755 /etc/init.d/rakitiw
    if pgrep -f "modemngentod.sh" > /dev/null; then
        echo "Menghentikan proses..."
        pkill -f "modemngentod.sh"
        echo "Proses telah dihentikan."
    fi
fi
exit 0
endef

define Package/$(PKG_NAME)/prerm
#!/bin/sh
# cek jika ini adalah uninstall atau upgrade
if [ "$${IPKG_INSTROOT}" = "" ]; then
    chmod -R 755 /usr/bin/modemngentod.sh
    chmod -R 755 /etc/init.d/rakitiw
    if [ -z "$${UPGRADE}" ]; then
        if pgrep -f "modemngentod.sh" > /dev/null; then
            echo "Menghentikan proses..."
            pkill -f "modemngentod.sh"
            echo "Proses telah dihentikan."
        fi
    fi
fi
exit 0
endef

include $(TOPDIR)/feeds/luci/luci.mk

# call BuildPackage - OpenWrt buildroot signature