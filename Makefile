include $(TOPDIR)/rules.mk

LUCI_TITLE:=Auto Reconect Modem Rakitan
PKG_NAME:=luci-app-rakitiw
LUCI_DEPENDS:=
PKG_VERSION:=1.1.6

define Package/$(PKG_NAME)/postinst
#!/bin/sh
# cek jika ini adalah install atau upgrade
if [ "$${IPKG_INSTROOT}" = "" ]; then
    chmod -R 755 /usr/bin/modemngentod.sh
    pid="$(pgrep -f modemngentod.sh)" && kill $pid
fi
exit 0
endef

define Package/$(PKG_NAME)/prerm
#!/bin/sh
# cek jika ini adalah uninstall atau upgrade
if [ "$${IPKG_INSTROOT}" = "" ]; then
    if [ -z "$${UPGRADE}" ]; then
        pid="$(pgrep -f modemngentod.sh)" && kill $pid
        crontab -l | grep -v '/usr/bin/modemngentod.sh' | crontab -
    fi
fi
exit 0
endef

include $(TOPDIR)/feeds/luci/luci.mk

# call BuildPackage - OpenWrt buildroot signature

