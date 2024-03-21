include $(TOPDIR)/rules.mk

LUCI_TITLE:=Auto Reconect Modem Rakitan
PKG_NAME:=luci-app-rakitiw
LUCI_DEPENDS:=
PKG_VERSION:=1.0.2

define Package/$(PKG_NAME)/install
#!/bin/sh
chmod -R 755 /usr/bin/modemngentod.sh
exit 0

endef

include $(TOPDIR)/feeds/luci/luci.mk

# call BuildPackage - OpenWrt buildroot signature