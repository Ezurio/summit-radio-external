################################################################################
#
# Summit network-manager
#
################################################################################
ifeq ($(BR2_PACKAGE_SUMMIT_NETWORK_MANAGER_60),y)
SUMMIT_NETWORK_MANAGER_VERSION = $(SUMMIT_60_RADIO_STACK_VERSION_VALUE)
SUMMIT_NETWORK_MANAGER_SITE = $(SUMMIT_RADIO_URI_BASE_60)-$(SUMMIT_NETWORK_MANAGER_VERSION)
else ifeq ($(BR2_PACKAGE_SUMMIT_NETWORK_MANAGER_LWB),y)
SUMMIT_NETWORK_MANAGER_VERSION = $(SUMMIT_LWB_RADIO_STACK_VERSION_VALUE)
SUMMIT_NETWORK_MANAGER_SITE = $(SUMMIT_RADIO_URI_BASE_LWB)-$(SUMMIT_NETWORK_MANAGER_VERSION)
else ifeq ($(BR2_PACKAGE_SUMMIT_NETWORK_MANAGER_MSD),y)
SUMMIT_NETWORK_MANAGER_VERSION = $(SUMMIT_MSD_RADIO_STACK_VERSION_VALUE)
SUMMIT_NETWORK_MANAGER_SITE = $(SUMMIT_RADIO_URI_BASE_MSD)-$(SUMMIT_NETWORK_MANAGER_VERSION)
else ifeq ($(BR2_PACKAGE_SUMMIT_NETWORK_MANAGER_NX),y)
SUMMIT_NETWORK_MANAGER_VERSION = $(SUMMIT_NX_RADIO_STACK_VERSION_VALUE)
SUMMIT_NETWORK_MANAGER_SITE = $(SUMMIT_RADIO_URI_BASE_NX)-$(SUMMIT_NETWORK_MANAGER_VERSION)
else ifeq ($(BR2_PACKAGE_SUMMIT_NETWORK_MANAGER_TI),y)
SUMMIT_NETWORK_MANAGER_VERSION = $(SUMMIT_TI_RADIO_STACK_VERSION_VALUE)
SUMMIT_NETWORK_MANAGER_SITE = $(SUMMIT_RADIO_URI_BASE_TI)-$(SUMMIT_NETWORK_MANAGER_VERSION)
else ifeq ($(BR2_PACKAGE_SUMMIT_NETWORK_MANAGER)$(BR_BUILDING),yy)
$(error "No target radio selected")
endif

ifeq ($(MSD_BINARIES_SOURCE_LOCATION),laird_internal)
  SUMMIT_NETWORK_MANAGER_SITE = $(SUMMIT_RADIO_URI_BASE_INTERNAL)/lrd-network-manager/src/$(SUMMIT_NETWORK_MANAGER_VERSION)
else ifeq ($(MSD_BINARIES_SOURCE_LOCATION),local)
  SUMMIT_NETWORK_MANAGER_VERSION = 0.$(BR2_SUMMIT_BRANCH).0.0
  BR_NO_CHECK_HASH_FOR += $(SUMMIT_NETWORK_MANAGER_SOURCE)
  SUMMIT_NETWORK_MANAGER_SITE = file://$(BASE_DIR)/../summit-network-manager-src/images
endif

SUMMIT_NETWORK_MANAGER_SOURCE = summit-network-manager-src-$(SUMMIT_NETWORK_MANAGER_VERSION).tar.xz
SUMMIT_NETWORK_MANAGER_INSTALL_STAGING = YES
SUMMIT_NETWORK_MANAGER_LICENSE = GPL-2.0+ (app), LGPL-2.1+ (libnm), Ezurio
SUMMIT_NETWORK_MANAGER_LICENSE_FILES = COPYING COPYING.LGPL CONTRIBUTING.md LICENSE.ezurio
SUMMIT_NETWORK_MANAGER_CPE_ID_VENDOR = gnome
SUMMIT_NETWORK_MANAGER_CPE_ID_PRODUCT = networkmanager
SUMMIT_NETWORK_MANAGER_CPE_ID_VERSION = 1.46.0
SUMMIT_NETWORK_MANAGER_SELINUX_MODULES = networkmanager

SUMMIT_NETWORK_MANAGER_DEPENDENCIES = \
	host-pkgconf \
	dbus \
	libglib2 \
	libndp \
	udev \
	util-linux \
	openssl

SUMMIT_NETWORK_MANAGER_CONF_OPTS = \
	-Ddocs=false \
	-Dtests=no \
	-Dqt=false \
	-Diptables=/usr/sbin/iptables \
	-Difupdown=false \
	-Difcfg_rh=false \
	-Dnm_cloud_setup=false \
	-Dsession_tracking_consolekit=false \
	-Dwext=false \
	-Dcrypto=openssl \
	-Diwd=false \
	-Dconfig_wifi_backend_default=wpa_supplicant

ifeq ($(BR2_PACKAGE_AUDIT),y)
SUMMIT_NETWORK_MANAGER_DEPENDENCIES += audit
SUMMIT_NETWORK_MANAGER_CONF_OPTS += -Dlibaudit=yes
else
SUMMIT_NETWORK_MANAGER_CONF_OPTS += -Dlibaudit=no
endif

ifeq ($(BR2_PACKAGE_DHCP_CLIENT),y)
SUMMIT_NETWORK_MANAGER_CONF_OPTS += -Ddhclient=/sbin/dhclient
else
SUMMIT_NETWORK_MANAGER_CONF_OPTS += -Ddhclient=no
endif

ifeq ($(BR2_PACKAGE_DHCPCD),y)
SUMMIT_NETWORK_MANAGER_CONF_OPTS += -Ddhcpcd=/sbin/dhcpcd
else
SUMMIT_NETWORK_MANAGER_CONF_OPTS += -Ddhcpcd=no
endif

ifeq ($(BR2_PACKAGE_SUMMIT_NETWORK_MANAGER_CONCHECK),y)
SUMMIT_NETWORK_MANAGER_DEPENDENCIES += libcurl
SUMMIT_NETWORK_MANAGER_CONF_OPTS += -Dconcheck=true
else
SUMMIT_NETWORK_MANAGER_CONF_OPTS += -Dconcheck=false
endif

ifeq ($(BR2_PACKAGE_LIBPSL),y)
SUMMIT_NETWORK_MANAGER_DEPENDENCIES += libpsl
SUMMIT_NETWORK_MANAGER_CONF_OPTS += -Dlibpsl=true
else
SUMMIT_NETWORK_MANAGER_CONF_OPTS += -Dlibpsl=false
endif

ifeq ($(BR2_PACKAGE_LIBSELINUX),y)
SUMMIT_NETWORK_MANAGER_DEPENDENCIES += libselinux
SUMMIT_NETWORK_MANAGER_CONF_OPTS += -Dselinux=true
else
SUMMIT_NETWORK_MANAGER_CONF_OPTS += -Dselinux=false
endif

ifeq ($(BR2_PACKAGE_SUMMIT_NETWORK_MANAGER_MODEM_MANAGER),y)
SUMMIT_NETWORK_MANAGER_DEPENDENCIES += modem-manager mobile-broadband-provider-info
SUMMIT_NETWORK_MANAGER_CONF_OPTS += -Dmodem_manager=true

ifeq ($(BR2_PACKAGE_OFONO),y)
SUMMIT_NETWORK_MANAGER_DEPENDENCIES += ofono
SUMMIT_NETWORK_MANAGER_CONF_OPTS += -Dofono=true
else
SUMMIT_NETWORK_MANAGER_CONF_OPTS += -Dofono=false
endif

ifeq ($(BR2_PACKAGE_BLUEZ5_UTILS),y)
SUMMIT_NETWORK_MANAGER_DEPENDENCIES += bluez5_utils
SUMMIT_NETWORK_MANAGER_CONF_OPTS += -Dbluez5_dun=true
else
SUMMIT_NETWORK_MANAGER_CONF_OPTS += -Dbluez5_dun=false
endif

else
SUMMIT_NETWORK_MANAGER_CONF_OPTS += -Dmodem_manager=false -Dofono=false -Dbluez5_dun=false
endif

ifeq ($(BR2_PACKAGE_SUMMIT_NETWORK_MANAGER_OVS),y)
SUMMIT_NETWORK_MANAGER_CONF_OPTS += -Dovs=true
SUMMIT_NETWORK_MANAGER_DEPENDENCIES += jansson
else
SUMMIT_NETWORK_MANAGER_CONF_OPTS += -Dovs=false
endif

ifeq ($(BR2_PACKAGE_SUMMIT_NETWORK_MANAGER_PPPD),y)
SUMMIT_NETWORK_MANAGER_DEPENDENCIES += pppd
SUMMIT_NETWORK_MANAGER_CONF_OPTS += \
	-Dppp=true \
	-Dpppd=/usr/sbin/pppd \
	-Dpppd_plugin_dir=/usr/lib/pppd/$(PPPD_VERSION)
else
SUMMIT_NETWORK_MANAGER_CONF_OPTS += -Dppp=false
endif

ifeq ($(BR2_PACKAGE_SUMMIT_NETWORK_MANAGER_TUI),y)
SUMMIT_NETWORK_MANAGER_DEPENDENCIES += newt
SUMMIT_NETWORK_MANAGER_CONF_OPTS += -Dnmtui=true
else
SUMMIT_NETWORK_MANAGER_CONF_OPTS += -Dnmtui=false
endif

ifeq ($(BR2_PACKAGE_SYSTEMD),y)
SUMMIT_NETWORK_MANAGER_DEPENDENCIES += systemd
SUMMIT_NETWORK_MANAGER_CONF_OPTS += \
	-Dsystemd_journal=true \
	-Dconfig_logging_backend_default=journal \
	-Dsession_tracking=systemd \
	-Dsuspend_resume=systemd
else
SUMMIT_NETWORK_MANAGER_CONF_OPTS += \
	-Dsystemd_journal=false \
	-Dconfig_logging_backend_default=syslog \
	-Dsession_tracking=no \
	-Dsuspend_resume=upower \
	-Dsystemdsystemunitdir=no
endif

ifeq ($(BR2_PACKAGE_POLKIT),y)
SUMMIT_NETWORK_MANAGER_DEPENDENCIES += polkit
SUMMIT_NETWORK_MANAGER_CONF_OPTS += -Dpolkit=true
else
SUMMIT_NETWORK_MANAGER_CONF_OPTS += -Dpolkit=false
endif

ifeq ($(BR2_PACKAGE_SUMMIT_NETWORK_MANAGER_CLI),y)
SUMMIT_NETWORK_MANAGER_DEPENDENCIES += readline
SUMMIT_NETWORK_MANAGER_CONF_OPTS += -Dnmcli=true
else
SUMMIT_NETWORK_MANAGER_CONF_OPTS += -Dnmcli=false
endif

ifeq ($(BR2_PACKAGE_GOBJECT_INTROSPECTION),y)
SUMMIT_NETWORK_MANAGER_DEPENDENCIES += gobject-introspection
SUMMIT_NETWORK_MANAGER_CONF_OPTS += -Dintrospection=true
else
SUMMIT_NETWORK_MANAGER_CONF_OPTS += -Dintrospection=false
endif

define SUMMIT_NETWORK_MANAGER_INSTALL_INIT_SYSV
	$(INSTALL) -m 0755 -D $(SUMMIT_NETWORK_MANAGER_PKGDIR)/S45network-manager \
		$(TARGET_DIR)/etc/init.d/S45network-manager
endef

define SUMMIT_NETWORK_MANAGER_INSTALL_INIT_SYSTEMD
	ln -sf /usr/lib/systemd/system/NetworkManager.service \
		$(TARGET_DIR)/etc/systemd/system/dbus-org.freedesktop.NetworkManager.service

	$(SED) 's,--no-daemon,--no-daemon --state-file=/etc/NetworkManager/NetworkManager.state,' \
		$(TARGET_DIR)/usr/lib/systemd/system/NetworkManager.service
endef

# create directories that may not be populated on certain builds
define SUMMIT_NETWORK_MANAGER_CREATE_EMPTY_DIRS
	$(INSTALL) -d $(TARGET_DIR)/etc/NetworkManager/certs \
		$(TARGET_DIR)/etc/NetworkManager/system-connections
endef

SUMMIT_NETWORK_MANAGER_TARGET_FINALIZE_HOOKS += SUMMIT_NETWORK_MANAGER_CREATE_EMPTY_DIRS

$(eval $(meson-package))
