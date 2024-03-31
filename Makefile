# See /LICENSE for more information.
# This is free software, licensed under the GNU General Public License v3.
# Copyright (C) 2024 rtaserver

include $(TOPDIR)/rules.mk

LUCI_TITLE:=Auto Reconect Modem Rakitan
PKG_NAME:=luci-app-rakitiw
LUCI_DEPENDS:=
PKG_VERSION:=1.1.9

define Package/$(PKG_NAME)/postinst
#!/bin/sh
# cek jika ini adalah install atau upgrade
if [ "$${IPKG_INSTROOT}" = "" ]; then
    chmod 0755 /usr/bin/modemngentod.sh
    chmod 0755 /etc/init.d/rakitiw
    if [ -f /var/run/modemngentod.pid ]; then
        modem_rakitan="Disabled"
        kill $(cat /var/run/modemngentod.pid)
        rm /var/run/modemngentod.pid
        pid=$(pgrep -f modemngentod.sh) && kill $pid
    else
        log "Rakitiw is not running."
    fi
fi
exit 0
endef

define Package/$(PKG_NAME)/prerm
#!/bin/sh
# cek jika ini adalah uninstall atau upgrade
if [ "$${IPKG_INSTROOT}" = "" ]; then
    chmod 0755 /usr/bin/modemngentod.sh
    chmod 0755 /etc/init.d/rakitiw
    if [ -f /var/run/modemngentod.pid ]; then
        modem_rakitan="Disabled"
        kill $(cat /var/run/modemngentod.pid)
        rm /var/run/modemngentod.pid
        pid=$(pgrep -f modemngentod.sh) && kill $pid
    else
        log "Rakitiw is not running."
    fi
fi
exit 0
endef

include $(TOPDIR)/feeds/luci/luci.mk

# call BuildPackage - OpenWrt buildroot signature