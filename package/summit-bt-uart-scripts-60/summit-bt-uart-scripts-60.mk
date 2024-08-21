#############################################################
#
# Summit Bluetooth UART Scripts for 60 Radio
#
#############################################################

SUMMIT_BT_UART_SCRIPTS_60_VERSION = local
SUMMIT_BT_UART_SCRIPTS_60_SITE = $(SUMMIT_BT_UART_SCRIPTS_60_PKGDIR)files
SUMMIT_BT_UART_SCRIPTS_60_SITE_METHOD = local
SUMMIT_BT_UART_SCRIPTS_60_LICENSE = Ezurio
SUMMIT_BT_UART_SCRIPTS_60_LICENSE_FILES = LICENSE.ezurio

define SUMMIT_BT_UART_SCRIPTS_60_INSTALL_TARGET_CMDS
	$(INSTALL) -D -m 0775 -t ${TARGET_DIR}/usr/bin \
		${@D}/bt-service.sh ${@D}/bttest.sh

	$(INSTALL) -d ${TARGET_DIR}/etc/default
	echo "PORT=${BR2_PACKAGE_SUMMIT_BT_UART_SCRIPTS_60_PORT}"  > ${TARGET_DIR}/etc/default/bt-service
	echo "BAUD=${BR2_PACKAGE_SUMMIT_BT_UART_SCRIPTS_60_BAUD}" >> ${TARGET_DIR}/etc/default/bt-service
endef 

define SUMMIT_BT_UART_SCRIPTS_60_INSTALL_INIT_SYSTEMD
	$(INSTALL) -D -m 0644 ${@D}/80-btattach.rules-sysd \
		${TARGET_DIR}/etc/udev/rules.d/80-btattach.rules
	$(INSTALL) -D -m 0644 -t ${TARGET_DIR}/usr/lib/systemd/system \
		${@D}/btattach.service
endef

define SUMMIT_BT_UART_SCRIPTS_60_INSTALL_INIT_SYSV
	$(INSTALL) -D -m 0644 ${@D}/80-btattach.rules-sysv \
		${TARGET_DIR}/etc/udev/rules.d/80-btattach.rules
endef

$(eval $(generic-package))
