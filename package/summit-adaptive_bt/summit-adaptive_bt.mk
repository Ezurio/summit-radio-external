#############################################################
#
# 60 Series Adaptive Bluetooth Power Daemon
#
#############################################################

SUMMIT_ADAPTIVE_BT_VERSION = $(call qstrip,$(SUMMIT_60_RADIO_STACK_VERSION_VALUE))
SUMMIT_ADAPTIVE_BT_SOURCE = adaptive_bt-src-$(SUMMIT_ADAPTIVE_BT_VERSION).tar.gz
SUMMIT_ADAPTIVE_BT_LICENSE = Ezurio
SUMMIT_ADAPTIVE_BT_LICENSE_FILES = LICENSE.ezurio

ifeq ($(MSD_BINARIES_SOURCE_LOCATION),laird_internal)
  SUMMIT_ADAPTIVE_BT_SITE = $(SUMMIT_RADIO_URI_BASE_INTERNAL)/adaptive_bt/src/$(SUMMIT_ADAPTIVE_BT_VERSION)
else ifeq ($(MSD_BINARIES_SOURCE_LOCATION),local)
  SUMMIT_ADAPTIVE_BT_VERSION = 0.$(BR2_SUMMIT_BRANCH).0.0
  BR_NO_CHECK_HASH_FOR += $(SUMMIT_ADAPTIVE_BT_SOURCE)
  SUMMIT_ADAPTIVE_BT_SITE = file://$(BASE_DIR)/../adaptive_bt-src/images
  SUMMIT_ADAPTIVE_BT_SOURCE = adaptive_bt-src.tar.gz
else
  SUMMIT_ADAPTIVE_BT_SITE = $(SUMMIT_RADIO_URI_BASE_60)-$(SUMMIT_ADAPTIVE_BT_VERSION)
endif

SUMMIT_ADAPTIVE_BT_DEPENDENCIES = host-pkgconf libnl bluez5_utils-headers

define SUMMIT_ADAPTIVE_BT_BUILD_CMDS
	$(TARGET_MAKE_ENV) $(MAKE) $(TARGET_CONFIGURE_OPTS) -C $(@D)
endef

define SUMMIT_ADAPTIVE_BT_INSTALL_TARGET_CMDS
	$(INSTALL) -D -m 0755 $(@D)/bin/adaptive_bt $(TARGET_DIR)/usr/bin/adaptive_bt
	$(ABT_STARTUP_INSTALL_TARGET_CMDS)
endef

define SUMMIT_ADAPTIVE_BT_INSTALL_INIT_SYSTEMD
	$(INSTALL) -m 0644 -D $(@D)/support/adaptive_bt.service \
		$(TARGET_DIR)/usr/lib/systemd/system/adaptive_bt.service
endef

define SUMMIT_ADAPTIVE_BT_INSTALL_INIT_SYSV
	$(INSTALL) -m 0755 -D $(@D)/support/adaptive_bt $(TARGET_DIR)/etc/init.d/S96adaptive_bt
endef

$(eval $(generic-package))
