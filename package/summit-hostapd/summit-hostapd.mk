#############################################################
#
# Summit hostapd
#
#############################################################

SUMMIT_HOSTAPD_VERSION = $(SUMMIT_RADIO_STACK_VERSION_VALUE)
SUMMIT_HOSTAPD_SOURCE = summit_supplicant-src-$(SUMMIT_HOSTAPD_VERSION).tar.gz

ifeq ($(MSD_BINARIES_SOURCE_LOCATION),laird_internal)
  SUMMIT_HOSTAPD_SITE = $(SUMMIT_RADIO_URI_BASE_INTERNAL)/summit_supplicant/laird/$(SUMMIT_HOSTAPD_VERSION)
else ifeq ($(MSD_BINARIES_SOURCE_LOCATION),local)
  SUMMIT_HOSTAPD_VERSION = 0.$(BR2_SUMMIT_BRANCH).0.0
  BR_NO_CHECK_HASH_FOR += $(SUMMIT_HOSTAPD_SOURCE)
  SUMMIT_HOSTAPD_SITE = file://$(BASE_DIR)/../summit_supplicant-src/images
  SUMMIT_HOSTAPD_SOURCE = summit_supplicant-src.tar.gz
else
  SUMMIT_HOSTAPD_SITE = $(SUMMIT_RADIO_URI_BASE)-$(SUMMIT_HOSTAPD_VERSION)
endif

SUMMIT_HOSTAPD_CPE_ID_VENDOR = w1.fi
SUMMIT_HOSTAPD_CPE_ID_PRODUCT = hostapd
SUMMIT_HOSTAPD_CPE_ID_VERSION = 2.10
SUMMIT_HOSTAPD_LICENSE = BSD-3-Clause Ezurio
SUMMIT_HOSTAPD_LICENSE_FILES = README LICENSE.ezurio
SUMMIT_HOSTAPD_DEPENDENCIES = host-pkgconf libnl openssl

SUMMIT_HOSTAPD_CONFIG = $(@D)/hostapd/config_openssl

define SUMMIT_HOSTAPD_BUILD_CMDS
	cp $(SUMMIT_HOSTAPD_CONFIG) $(@D)/hostapd/.config
	$(TARGET_MAKE_ENV) $(TARGET_CONFIGURE_OPTS) $(MAKE) -C $(@D)/hostapd
endef

ifeq ($(BR2_PACKAGE_SUMMIT_HOSTAPD_HOSTAPD_CLI),y)
define SUMMIT_HOSTAPD_INSTALL_HOSTAPD_CLI
	$(INSTALL) -D -m 755 $(@D)/hostapd/hostapd_cli $(TARGET_DIR)/usr/sbin/hostapd_cli
endef
endif

define SUMMIT_HOSTAPD_INSTALL_TARGET_CMDS
	$(INSTALL) -D -m 755 $(@D)/hostapd/hostapd $(TARGET_DIR)/usr/sbin/hostapd
	$(SUMMIT_HOSTAPD_INSTALL_HOSTAPD_CLI)
endef

$(eval $(generic-package))
