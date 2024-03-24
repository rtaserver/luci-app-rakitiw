include $(TOPDIR)/rules.mk

LUCI_TITLE:=Auto Reconnect Modem Rakitan
PKG_NAME:=luci-app-rakitiw
LUCI_DEPENDS:=
PKG_VERSION:=1.1.1

define Package/$(PKG_NAME)/postinst
	#!/bin/sh
	# check if this is upgrade or reinstall
	if [ "$${IPKG_INSTROOT}" = "" ]; then
		chmod -R 755 /usr/bin/modemngentod.sh
		pid=$$(pgrep -f modemngentod.sh)
		
		if [ -z "$$pid" ]; then
			echo "Process is not running."
		else
			kill $$pid
			echo "Process with PID $$pid has been stopped."
		fi
	fi
	exit 0
endef

define Package/$(PKG_NAME)/prerm
	#!/bin/sh
	# check if this is uninstall or upgrade
	if [ "$${IPKG_UPGRADE}" = "1" -o "$${IPKG_INSTROOT}" = "" ]; then
		pid=$$(pgrep -f modemngentod.sh)

		if [ -z "$$pid" ]; then
			echo "Process is not running."
		else
			kill $$pid
			echo "Process with PID $$pid has been stopped."
		fi

		crontab -l | grep -v '/usr/bin/modemngentod.sh' | crontab -
	fi
	exit 0
endef

include $(TOPDIR)/feeds/luci/luci.mk
