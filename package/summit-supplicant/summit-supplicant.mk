#############################################################
#
# Summit Supplicant
#
#############################################################
ifeq ($(BR2_PACKAGE_SUMMIT_SUPPLICANT_60),y)
SUMMIT_SUPPLICANT_VERSION = $(SUMMIT_60_RADIO_STACK_VERSION_VALUE)
SUMMIT_SUPPLICANT_SITE = $(SUMMIT_RADIO_URI_BASE_60)-$(SUMMIT_SUPPLICANT_VERSION)
else ifeq ($(BR2_PACKAGE_SUMMIT_SUPPLICANT_LWB),y)
SUMMIT_SUPPLICANT_VERSION = $(SUMMIT_LWB_RADIO_STACK_VERSION_VALUE)
SUMMIT_SUPPLICANT_SITE = $(SUMMIT_RADIO_URI_BASE_LWB)-$(SUMMIT_SUPPLICANT_VERSION)
else ifeq ($(BR2_PACKAGE_SUMMIT_SUPPLICANT_MSD),y)
SUMMIT_SUPPLICANT_VERSION = $(SUMMIT_MSD_RADIO_STACK_VERSION_VALUE)
SUMMIT_SUPPLICANT_SITE = $(SUMMIT_RADIO_URI_BASE_MSD)-$(SUMMIT_SUPPLICANT_VERSION)
else ifeq ($(BR2_PACKAGE_SUMMIT_SUPPLICANT_NX),y)
SUMMIT_SUPPLICANT_VERSION = $(SUMMIT_NX_RADIO_STACK_VERSION_VALUE)
SUMMIT_SUPPLICANT_SITE = $(SUMMIT_RADIO_URI_BASE_NX)-$(SUMMIT_SUPPLICANT_VERSION)
else ifeq ($(BR2_PACKAGE_SUMMIT_SUPPLICANT_TI),y)
SUMMIT_SUPPLICANT_VERSION = $(SUMMIT_TI_RADIO_STACK_VERSION_VALUE)
SUMMIT_SUPPLICANT_SITE = $(SUMMIT_RADIO_URI_BASE_TI)-$(SUMMIT_SUPPLICANT_VERSION)
else ifeq ($(BR2_PACKAGE_SUMMIT_SUPPLICANT)$(BR_BUILDING),yy)
$(error "No target radio selected")
endif

SUMMIT_SUPPLICANT_SOURCE = summit_supplicant-src-$(SUMMIT_SUPPLICANT_VERSION).tar.gz

ifeq ($(MSD_BINARIES_SOURCE_LOCATION),laird_internal)
SUMMIT_SUPPLICANT_SITE = $(SUMMIT_RADIO_URI_BASE_INTERNAL)/summit_supplicant/laird/$(SUMMIT_SUPPLICANT_VERSION)
else ifeq ($(MSD_BINARIES_SOURCE_LOCATION),local)
  SUMMIT_SUPPLICANT_VERSION = 0.$(BR2_SUMMIT_BRANCH).0.0
  BR_NO_CHECK_HASH_FOR += $(SUMMIT_SUPPLICANT_SOURCE)
  SUMMIT_SUPPLICANT_SITE = file://$(BASE_DIR)/../summit_supplicant-src/images
  SUMMIT_SUPPLICANT_SOURCE = summit_supplicant-src.tar.gz
endif

SUMMIT_SUPPLICANT_SOURCE = summit_supplicant-src-$(SUMMIT_SUPPLICANT_VERSION).tar.gz

SUMMIT_SUPPLICANT_CPE_ID_VENDOR = w1.fi
SUMMIT_SUPPLICANT_CPE_ID_PRODUCT = wpa_supplicant
SUMMIT_SUPPLICANT_CPE_ID_VERSION = 2.10
SUMMIT_SUPPLICANT_LICENSE = BSD-3-Clause Ezurio
SUMMIT_SUPPLICANT_LICENSE_FILES = README LICENSE.ezurio
SUMMIT_SUPPLICANT_INSTALL_STAGING = YES
SUMMIT_SUPPLICANT_DEPENDENCIES = host-pkgconf libnl openssl

ifeq ($(BR2_PACKAGE_SUMMIT_SUPPLICANT_LIBS),y)
SUMMIT_SUPPLICANT_DEPENDENCIES += summit-supplicant-libs
endif

ifeq ($(BR2_PACKAGE_SUMMIT_SUPPLICANT_FIPS),y)
SUMMIT_SUPPLICANT_FIPS = CONFIG_FIPS=y
SUMMIT_SUPPLICANT_FIPS += CONFIG_FIPS_SUMMIT=y
endif

ifeq ($(BR2_PACKAGE_LIBOPENSSL_3_0),y)
ifeq ($(BR2_PACKAGE_LIBOPENSSL_ENABLE_FIPS),y)
SUMMIT_SUPPLICANT_FIPS = CONFIG_FIPS=y
SUMMIT_SUPPLICANT_FIPS += CONFIG_FIPS_SUMMIT=y
endif
endif

ifeq ($(BR2_PACKAGE_SUMMIT_SUPPLICANT_LEGACY),y)
ifeq ($(BR2_PACKAGE_SUMMIT_SUPPLICANT_LIBS_BUILD),y)
    SUMMIT_SUPPLICANT_DEPENDENCIES += sdcsdk
endif
    SUMMIT_SUPPLICANT_CONFIG = $(@D)/wpa_supplicant/config_legacy
else
    SUMMIT_SUPPLICANT_DEPENDENCIES += dbus
    SUMMIT_SUPPLICANT_CONFIG = $(@D)/wpa_supplicant/config_openssl
endif

define SUMMIT_SUPPLICANT_BUILD_CMDS
	cp $(SUMMIT_SUPPLICANT_CONFIG) $(@D)/wpa_supplicant/.config
	$(TARGET_MAKE_ENV) $(TARGET_CONFIGURE_OPTS) $(MAKE) -C $(@D)/wpa_supplicant BINDIR=/usr/sbin $(SUMMIT_SUPPLICANT_FIPS)
	$(TARGET_OBJCOPY) $(@D)/wpa_supplicant/wpa_supplicant $(@D)/wpa_supplicant/sdcsupp
endef

ifeq ($(BR2_PACKAGE_SUMMIT_SUPPLICANT_WPA_CLI),y)
define SUMMIT_SUPPLICANT_INSTALL_WPA_CLI
	$(INSTALL) -D -m 755 -t $(TARGET_DIR)/usr/sbin $(@D)/wpa_supplicant/wpa_cli
endef
endif

ifeq ($(BR2_PACKAGE_SUMMIT_SUPPLICANT_WPA_PASSPHRASE),y)
define SUMMIT_SUPPLICANT_INSTALL_WPA_PASSPHRASE
	$(INSTALL) -D -m 755 -t $(TARGET_DIR)/usr/sbin $(@D)/wpa_supplicant/wpa_passphrase
endef
endif

ifneq ($(BR2_PACKAGE_SUMMIT_SUPPLICANT_LEGACY),y)

ifeq ($(BR2_PACKAGE_WPA_SUPPLICANT),y)
    # both wpa_supplicant and sdcsupp installed, postfix to avoid collision
    SUMMIT_SUPPLICANT_DBUS_SERVICE_POSTFIX = .summit
else
    # only sdcsupp installed, no postfix needed
    SUMMIT_SUPPLICANT_DBUS_SERVICE_POSTFIX =
endif

ifneq ($(BR2_PACKAGE_SUMMIT_SUPPLICANT_DBUS_P2P_ENABLED),y)
define SUMMIT_SUPPLICANT_INSTALL_DBUS_OVERLAY_CONF
	mkdir -p $(TARGET_DIR)/etc/wpa_supplicant
	@echo "p2p_disabled=1" > $(TARGET_DIR)/etc/wpa_supplicant/dbus_overlay.conf
endef
endif

define SUMMIT_SUPPLICANT_INSTALL_DBUS
	$(INSTALL) -m 0644 -D $(@D)/wpa_supplicant/dbus/dbus-wpa_supplicant.conf \
		$(TARGET_DIR)/etc/dbus-1/system.d/wpa_supplicant.conf
	$(INSTALL) -m 0644 -D $(@D)/wpa_supplicant/dbus/fi.w1.wpa_supplicant1.service \
		$(TARGET_DIR)/usr/share/dbus-1/system-services/fi.w1.wpa_supplicant1.service$(SUMMIT_SUPPLICANT_DBUS_SERVICE_POSTFIX)
	$(SUMMIT_SUPPLICANT_INSTALL_DBUS_OVERLAY_CONF)
endef

define SUMMIT_SUPPLICANT_INSTALL_WPA_CLIENT_SO
	$(INSTALL) -m 0644 -D $(@D)/$(WPA_SUPPLICANT_SUBDIR)/libwpa_client.so \
		$(TARGET_DIR)/usr/lib/libwpa_client.so
endef

define SUMMIT_SUPPLICANT_INSTALL_STAGING_WPA_CLIENT_SO
	$(INSTALL) -m 0644 -D -t $(STAGING_DIR)/usr/lib \
		$(@D)/$(WPA_SUPPLICANT_SUBDIR)/libwpa_client.so
	$(INSTALL) -m 0644 -D -t $(STAGING_DIR)/usr/include \
		$(@D)/src/common/wpa_ctrl.h
endef

endif

ifeq ($(BR2_PACKAGE_SUMMIT_SUPPLICANT_LIBS_BUILD),y)
define SUMMIT_SUPPLICANT_INSTALL_SUMMIT_SUPPLICANT_SO
	$(INSTALL) -m 0644 -D -t $(TARGET_DIR)/usr/lib \
		$(@D)/$(WPA_SUPPLICANT_SUBDIR)/libsdcsupp.so
endef

define SUMMIT_SUPPLICANT_INSTALL_STAGING_SUMMIT_SUPPLICANT_SO
	$(INSTALL) -m 0644 -D -t $(STAGING_DIR)/usr/lib \
		$(@D)/$(WPA_SUPPLICANT_SUBDIR)/libsdcsupp.so
endef
endif

define SUMMIT_SUPPLICANT_INSTALL_STAGING_CMDS
	$(SUMMIT_SUPPLICANT_INSTALL_STAGING_WPA_CLIENT_SO)
	$(SUMMIT_SUPPLICANT_INSTALL_STAGING_SUMMIT_SUPPLICANT_SO)
endef

define SUMMIT_SUPPLICANT_INSTALL_TARGET_CMDS
	$(INSTALL) -D -m 755 -t $(TARGET_DIR)/usr/sbin $(@D)/wpa_supplicant/sdcsupp
	$(SUMMIT_SUPPLICANT_INSTALL_WPA_CLI)
	$(SUMMIT_SUPPLICANT_INSTALL_WPA_PASSPHRASE)
	$(SUMMIT_SUPPLICANT_INSTALL_DBUS)
	$(SUMMIT_SUPPLICANT_INSTALL_WPA_CLIENT_SO)
	$(SUMMIT_SUPPLICANT_INSTALL_SUMMIT_SUPPLICANT_SO)
endef

define SUMMIT_SUPPLICANT_INSTALL_INIT_SYSTEMD
	$(INSTALL) -m 0644 -D $(@D)/wpa_supplicant/systemd/wpa_supplicant.service \
		$(TARGET_DIR)/usr/lib/systemd/system/wpa_supplicant.service
	$(INSTALL) -m 0644 -D $(@D)/wpa_supplicant/systemd/wpa_supplicant@.service \
		$(TARGET_DIR)/usr/lib/systemd/system/wpa_supplicant@.service
	$(INSTALL) -m 0644 -D $(@D)/wpa_supplicant/systemd/wpa_supplicant-nl80211@.service \
		$(TARGET_DIR)/usr/lib/systemd/system/wpa_supplicant-nl80211@.service
	$(INSTALL) -m 0644 -D $(@D)/wpa_supplicant/systemd/wpa_supplicant-wired@.service \
		$(TARGET_DIR)/usr/lib/systemd/system/wpa_supplicant-wired@.service
	$(INSTALL) -m 0644 -D $(SUMMIT_SUPPLICANT_PKGDIR)/50-wpa_supplicant.preset \
		$(TARGET_DIR)/usr/lib/systemd/system-preset/50-wpa_supplicant.preset
endef

$(eval $(generic-package))
