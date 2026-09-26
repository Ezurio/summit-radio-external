ifneq ($(BR2_LRD_DEVEL_BUILD),y)

SUMMIT_FIRMWARE_MT320_SDIO_VERSION = $(SUMMIT_RADIO_STACK_VERSION_VALUE)
SUMMIT_FIRMWARE_MT320_SDIO_SOURCE = summit-mt320-sdio-firmware-$(SUMMIT_FIRMWARE_MT320_SDIO_VERSION).tar.bz2
SUMMIT_FIRMWARE_MT320_SDIO_STRIP_COMPONENTS = 0
SUMMIT_FIRMWARE_MT320_SDIO_LICENSE = MediaTek, Ezurio
SUMMIT_FIRMWARE_MT320_SDIO_LICENSE_FILES = LICENSE.ezurio
SUMMIT_FIRMWARE_MT320_REGDOMAIN = $(call qstrip,$(BR2_PACKAGE_SUMMIT_FIRMWARE_MT320_REGDOMAIN))

ifeq ($(MSD_BINARIES_SOURCE_LOCATION),laird_internal)
  SUMMIT_FIRMWARE_MT320_SDIO_SITE = $(SUMMIT_RADIO_URI_BASE_INTERNAL)/firmware/$(SUMMIT_FIRMWARE_MT320_SDIO_VERSION)
else ifeq ($(MSD_BINARIES_SOURCE_LOCATION),local)
  SUMMIT_FIRMWARE_MT320_SDIO_VERSION = 0.$(BR2_SUMMIT_BRANCH).0.0
  BR_NO_CHECK_HASH_FOR += $(SUMMIT_FIRMWARE_MT320_SDIO_SOURCE)
  SUMMIT_FIRMWARE_MT320_SDIO_SITE = file://$(BASE_DIR)/../firmware/images
else
  SUMMIT_FIRMWARE_MT320_SDIO_SITE = $(SUMMIT_RADIO_URI_BASE)-$(SUMMIT_FIRMWARE_MT320_SDIO_VERSION)
endif

ifneq ($(shell printf '%s' "$(SUMMIT_FIRMWARE_MT320_REGDOMAIN)" | grep -Eq '^[A-Z][A-Z]$$' && echo y),y)
ifneq ($(SUMMIT_FIRMWARE_MT320_REGDOMAIN),)
$(error BR2_PACKAGE_SUMMIT_FIRMWARE_MT320_REGDOMAIN must be two uppercase letters or empty)
endif
endif
ifneq ($(SUMMIT_FIRMWARE_MT320_REGDOMAIN),)
define SUMMIT_FIRMWARE_MT320_INSTALL_REGDOMAIN
  $(INSTALL) -d -m 0755 $(TARGET_DIR)/etc/modprobe.d
  printf 'options wlan_mt7961_sdio regdomain=%s\n' \
    "$(SUMMIT_FIRMWARE_MT320_REGDOMAIN)" \
    > $(TARGET_DIR)/etc/modprobe.d/wlan_mt7961_sdio.conf
endef
endif

define SUMMIT_FIRMWARE_MT320_SDIO_INSTALL_TARGET_CMDS
  # Gen4 WLAN requests WiFi firmware and TxPwrLimit data from the root
  # firmware directory. btmtksdio independently requests its firmware
  # from the mediatek/ namespace.
  $(INSTALL) -D -m 0644 -t $(TARGET_DIR)/lib/firmware \
    $(@D)/lib/firmware/WIFI_*.bin \
    $(@D)/lib/firmware/TxPwrLimit_MT79x1.dat
  $(INSTALL) -D -m 0644 -t $(TARGET_DIR)/lib/firmware/mediatek \
    $(@D)/lib/firmware/mediatek/BT_RAM_CODE_MT7961_1_2_hdr.bin
  $(SUMMIT_FIRMWARE_MT320_INSTALL_REGDOMAIN)
endef

endif

$(eval $(generic-package))
