# See /LICENSE for more information.
# This is free software, licensed under the GNU General Public License v3.
# Copyright (C) 2024 rtaserver

include $(TOPDIR)/rules.mk

LUCI_TITLE:=Auto Reconnect Modem Rakitan
PKG_NAME:=luci-app-rakitiw
LUCI_DEPENDS:=+modemmanager +python3-pip +jq
PKG_VERSION:=1.2.5
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

define Package/$(PKG_NAME)/install
  $(INSTALL_DIR) $(1)/usr/lib/lua/luci
  $(CP) ./luasrc/* $(1)/usr/lib/lua/luci/
  $(INSTALL_DIR) $(1)/
  $(CP) ./root/* $(1)/
  chmod 755 $(1)/root/www/*
  chmod 755 $(1)/root/etc/init.d/*
  chmod 755 $(1)/root/etc/uci-defaults/*
  chmod 755 $(1)/root/usr/bin/*
endef

define Package/$(PKG_NAME)/postinst
#!/bin/sh
if [ -f /var/run/rakitanmanager.pid ]; then
    rm /var/run/rakitanmanager.pid
    killall -9 rakitanmanager.sh
else
    echo "Rakitiw is not running."
fi
[ -d /tmp/luci-modulecache ] && rm -rf /tmp/luci-modulecache
find /tmp -type f -name 'luci-indexcache.*' -exec rm -f {} \;
chmod 755 $(1)/usr/lib/lua/luci/controller/*
chmod 755 $(1)/usr/lib/lua/luci/view/*
chmod 755 $(1)/www/*
chmod 755 $(1)/www/rakitiw/*
chmod 755 $(1)/etc/init.d/rakitiw
chmod 755 $(1)/usr/bin/rakitanmanager.sh
chmod 755 $(1)/usr/bin/modem-orbit.py
# Autofix download index.php, index.html
if ! grep -q ".php=/usr/bin/php-cgi" /etc/config/uhttpd; then
    echo -e "  rtalog : system not using php-cgi, patching php config ..."
    logger "  rtalog : system not using php-cgi, patching php config..."
    uci set uhttpd.main.ubus_prefix='/ubus'
    uci set uhttpd.main.interpreter='.php=/usr/bin/php-cgi'
    uci set uhttpd.main.index_page='cgi-bin/luci'
    uci add_list uhttpd.main.index_page='index.html'
    uci add_list uhttpd.main.index_page='index.php'
    uci commit uhttpd
    echo -e "  rtalog : patching system with php configuration done ..."
    echo -e "  rtalog : restarting some apps ..."
    logger "  rtalog : patching system with php configuration done..."
    logger "  rtalog : restarting some apps..."
    /etc/init.d/uhttpd restart
fi
[ -d /usr/lib/php8 ] && [ ! -d /usr/lib/php ] && ln -sf /usr/lib/php8 /usr/lib/php
exit 0
endef

define Package/$(PKG_NAME)/postrm
#!/bin/sh
export NAMAPAKET="rakitiw"
if [ -d /www/$NAMAPAKET ] ; then
    rm -rf /www/$NAMAPAKET
fi
unset NAMAPAKET
if [ -f /var/run/rakitanmanager.pid ]; then
    rm /var/run/rakitanmanager.pid
    killall -9 rakitanmanager.sh
else
    echo "Rakitiw is not running."
fi
exit 0
endef

include $(TOPDIR)/feeds/luci/luci.mk

$(eval $(call BuildPackage,$(PKG_NAME)))