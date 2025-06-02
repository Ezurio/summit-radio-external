ifneq ($(BR2_LRD_DEVEL_BUILD),y)

SUMMIT_FIRMWARE_NX_VERSION = $(SUMMIT_NX_RADIO_STACK_VERSION_VALUE)
SUMMIT_FIRMWARE_NX_SOURCE = $(firstword $(SUMMIT_FIRMWARE_NX_DOWNLOADS))
SUMMIT_FIRMWARE_NX_EXTRA_DOWNLOADS = $(filter-out $(SUMMIT_FIRMWARE_NX_SOURCE),$(SUMMIT_FIRMWARE_NX_DOWNLOADS))
SUMMIT_FIRMWARE_NX_STRIP_COMPONENTS = 0
SUMMIT_FIRMWARE_NX_LICENSE = NXP, Ezurio
SUMMIT_FIRMWARE_NX_LICENSE_FILES = LICENSE.nxp2 LICENSE.ezurio

ifeq ($(MSD_BINARIES_SOURCE_LOCATION),laird_internal)
  SUMMIT_FIRMWARE_NX_SITE = $(SUMMIT_RADIO_URI_BASE_INTERNAL)/firmware/$(SUMMIT_FIRMWARE_NX_VERSION)
else ifeq ($(MSD_BINARIES_SOURCE_LOCATION),local)
  SUMMIT_FIRMWARE_NX_VERSION = 0.$(BR2_SUMMIT_BRANCH).0.0
  BR_NO_CHECK_HASH_FOR += $(SUMMIT_FIRMWARE_NX_DOWNLOADS)
  SUMMIT_FIRMWARE_NX_SITE = file://$(BASE_DIR)/../firmware/images
else
  SUMMIT_FIRMWARE_NX_SITE = $(SUMMIT_RADIO_URI_BASE_NX)-$(SUMMIT_FIRMWARE_NX_VERSION)
endif

ifeq ($(BR2_PACKAGE_SUMMIT_FIRMWARE_NX61X),y)
  SUMMIT_FIRMWARE_NX_DOWNLOADS += summit-nx61x-firmware-$(SUMMIT_FIRMWARE_NX_VERSION).tar.bz2
endif

ifeq ($(BR2_PACKAGE_SUMMIT_FIRMWARE_NX61X_SERDEV),y)
define SUMMIT_FIRMWARE_NX_INSTALL_TARGET_CMDS
  $(INSTALL) -D -m 0644 -t $(TARGET_DIR)/lib/firmware/nxp \
    $(@D)/lib/firmware/nxp/sd_* \
    $(@D)/lib/firmware/nxp/uart* \
    $(@D)/lib/firmware/nxp/*rgpower* \
    $(@D)/lib/firmware/nxp/wifi_prod_serdev_params.conf

  $(INSTALL) -d $(TARGET_DIR)/etc/modprobe.d
  echo "options moal mod_para=nxp/wifi_prod_serdev_params.conf" > \
    $(TARGET_DIR)/etc/modprobe.d/moal.conf
endef
else
define SUMMIT_FIRMWARE_NX_INSTALL_TARGET_CMDS
  $(INSTALL) -D -m 0644 -t $(TARGET_DIR)/lib/firmware/nxp \
    $(@D)/lib/firmware/nxp/sduart_* \
    $(@D)/lib/firmware/nxp/*rgpower* \
    $(@D)/lib/firmware/nxp/wifi_prod_params.conf

  $(INSTALL) -d $(TARGET_DIR)/etc/modprobe.d
  echo "options moal mod_para=nxp/wifi_prod_params.conf" > \
    $(TARGET_DIR)/etc/modprobe.d/moal.conf
endef
endif

endif

$(eval $(generic-package))
