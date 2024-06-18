################################################################################
#
# summit-linux-backports
#
################################################################################

ifeq ($(BR2_PACKAGE_SUMMIT_LINUX_BACKPORTS_60),y)
SUMMIT_LINUX_BACKPORTS_VERSION = $(SUMMIT_60_RADIO_STACK_VERSION_VALUE)
SUMMIT_LINUX_BACKPORTS_SITE = $(SUMMIT_RADIO_URI_BASE_60)-$(SUMMIT_LINUX_BACKPORTS_VERSION)
else ifeq ($(BR2_PACKAGE_SUMMIT_LINUX_BACKPORTS_BDSDMAC),y)
SUMMIT_LINUX_BACKPORTS_VERSION = $(SUMMIT_BDSDMAC_RADIO_STACK_VERSION_VALUE)
SUMMIT_LINUX_BACKPORTS_SITE = $(SUMMIT_RADIO_URI_BASE_BDSDMAC)-$(SUMMIT_LINUX_BACKPORTS_VERSION)
else ifeq ($(BR2_PACKAGE_SUMMIT_LINUX_BACKPORTS_LWB),y)
SUMMIT_LINUX_BACKPORTS_VERSION = $(SUMMIT_LWB_RADIO_STACK_VERSION_VALUE)
SUMMIT_LINUX_BACKPORTS_SITE = $(SUMMIT_RADIO_URI_BASE_LWB)-$(SUMMIT_LINUX_BACKPORTS_VERSION)
else ifeq ($(BR2_PACKAGE_SUMMIT_LINUX_BACKPORTS_MSD),y)
SUMMIT_LINUX_BACKPORTS_VERSION = $(SUMMIT_MSD_RADIO_STACK_VERSION_VALUE)
SUMMIT_LINUX_BACKPORTS_SITE = $(SUMMIT_RADIO_URI_BASE_MSD)-$(SUMMIT_LINUX_BACKPORTS_VERSION)
else ifeq ($(BR2_PACKAGE_SUMMIT_LINUX_BACKPORTS_NX),y)
SUMMIT_LINUX_BACKPORTS_VERSION = $(SUMMIT_NX_RADIO_STACK_VERSION_VALUE)
SUMMIT_LINUX_BACKPORTS_SITE = $(SUMMIT_RADIO_URI_BASE_NX)-$(SUMMIT_LINUX_BACKPORTS_VERSION)
else ifeq ($(BR2_PACKAGE_SUMMIT_LINUX_BACKPORTS_TI),y)
SUMMIT_LINUX_BACKPORTS_VERSION = $(SUMMIT_TI_RADIO_STACK_VERSION_VALUE)
SUMMIT_LINUX_BACKPORTS_SITE = $(SUMMIT_RADIO_URI_BASE_TI)-$(SUMMIT_LINUX_BACKPORTS_VERSION)
else ifeq ($(BR2_PACKAGE_SUMMIT_LINUX_BACKPORTS_LOCAL),y)
ifneq ($(VERSION),)
SUMMIT_LINUX_BACKPORTS_VERSION = $(VERSION)
else
SUMMIT_LINUX_BACKPORTS_VERSION = 0.$(BR2_SUMMIT_BRANCH).0.0
endif
SUMMIT_LINUX_BACKPORTS_SITE = $(SUMMIT_RADIO_URI_BASE_60)-$(SUMMIT_LINUX_BACKPORTS_VERSION)
BR_NO_CHECK_HASH_FOR += $(SUMMIT_LINUX_BACKPORTS_SOURCE)
else ifeq ($(BR2_PACKAGE_SUMMIT_LINUX_BACKPORTS)$(BR_BUILDING),yy)
$(error "No target radio selected")
endif

ifeq ($(MSD_BINARIES_SOURCE_LOCATION),laird_internal)
SUMMIT_LINUX_BACKPORTS_SITE = $(SUMMIT_RADIO_URI_BASE_INTERNAL)/backports/laird/$(SUMMIT_LINUX_BACKPORTS_VERSION)
else ifeq ($(MSD_BINARIES_SOURCE_LOCATION),local)
  SUMMIT_LINUX_BACKPORTS_VERSION = 0.$(BR2_SUMMIT_BRANCH).0.0
  BR_NO_CHECK_HASH_FOR += $(SUMMIT_LINUX_BACKPORTS_SOURCE)
  SUMMIT_LINUX_BACKPORTS_SITE = file://$(BASE_DIR)/../backports/images
endif

SUMMIT_LINUX_BACKPORTS_SOURCE = summit-backports-$(SUMMIT_LINUX_BACKPORTS_VERSION).tar.bz2

SUMMIT_LINUX_BACKPORTS_INSTALL_STAGING = YES
SUMMIT_LINUX_BACKPORTS_MINIMAL_KVER_MAJOR = 3
SUMMIT_LINUX_BACKPORTS_MINIMAL_KVER_MINOR = 0
SUMMIT_LINUX_BACKPORTS_LICENSE = GPL-2.0 Ezurio
SUMMIT_LINUX_BACKPORTS_LICENSE_FILES = \
	COPYING \
	LICENSE.ezurio \
	LICENSES/exceptions/Linux-syscall-note \
	LICENSES/preferred/GPL-2.0

# flex and bison are needed to generate kconfig parser. We use the
# same logic as the linux kernel (we add host dependencies only if
# host does not have them). See linux/linux.mk and
# support/dependencies/check-host-bison-flex.mk.
SUMMIT_LINUX_BACKPORTS_KCONFIG_DEPENDENCIES = \
	$(BR2_BISON_HOST_DEPENDENCY) \
	$(BR2_FLEX_HOST_DEPENDENCY)

ifeq ($(BR2_PACKAGE_SUMMIT_LINUX_BACKPORTS_USE_DEFCONFIG),y)
SUMMIT_LINUX_BACKPORTS_KCONFIG_FILE = $(SUMMIT_LINUX_BACKPORTS_DIR)/defconfigs/$(call qstrip,$(BR2_PACKAGE_SUMMIT_LINUX_BACKPORTS_DEFCONFIG))
else ifeq ($(BR2_PACKAGE_SUMMIT_LINUX_BACKPORTS_USE_CUSTOM_CONFIG),y)
SUMMIT_LINUX_BACKPORTS_KCONFIG_FILE = $(call qstrip,$(BR2_PACKAGE_SUMMIT_LINUX_BACKPORTS_CUSTOM_CONFIG_FILE))
endif

SUMMIT_LINUX_BACKPORTS_KCONFIG_FRAGMENT_FILES = $(call qstrip,$(BR2_PACKAGE_SUMMIT_LINUX_BACKPORTS_CONFIG_FRAGMENT_FILES))
SUMMIT_LINUX_BACKPORTS_KCONFIG_OPTS = $(SUMMIT_LINUX_BACKPORTS_MAKE_OPTS)

SUMMIT_LINUX_BACKPORTS_MAKE_ENV = $(HOST_MAKE_ENV)

# linux-backports' build system expects the config options to be present
# in the environment, and it is so when using their custom buildsystem,
# because they are set in the main Makefile, which then calls a second
# Makefile.
#
# In our case, we do not use that first Makefile. So, we parse the
# .config file, filter-out comment lines and put the rest as command
# line variables.
#
# SUMMIT_LINUX_BACKPORTS_MAKE_OPTS is used by the kconfig-package infra, while
# SUMMIT_LINUX_BACKPORTS_MODULE_MAKE_OPTS is used by the kernel-module infra.
#
SUMMIT_LINUX_BACKPORTS_MAKE_OPTS = \
	KLIB_BUILD=$(LINUX_DIR) \
	KLIB=$(TARGET_DIR)/lib/modules/$(LINUX_VERSION_PROBED) \
	INSTALL_MOD_DIR=updates

SUMMIT_LINUX_BACKPORTS_MODULE_MAKE_OPTS = $(SUMMIT_LINUX_BACKPORTS_MAKE_OPTS)

define SUMMIT_LINUX_BACKPORTS_INSTALL_STAGING_CMDS
	rsync -rlpDWK --no-perms --inplace --exclude module.h $(@D)/include $(@D)/backport-include $(STAGING_DIR)/usr/include/linux-backports
endef

# Checks to give errors that the user can understand
ifeq ($(BR_BUILDING),y)

ifeq ($(BR2_PACKAGE_SUMMIT_LINUX_BACKPORTS_USE_DEFCONFIG),y)
ifeq ($(call qstrip,$(BR2_PACKAGE_SUMMIT_LINUX_BACKPORTS_DEFCONFIG)),)
$(error No linux-backports defconfig name specified, check your BR2_PACKAGE_SUMMIT_LINUX_BACKPORTS_DEFCONFIG setting)
endif
endif

ifeq ($(BR2_PACKAGE_SUMMIT_LINUX_BACKPORTS_USE_CUSTOM_CONFIG),y)
ifeq ($(call qstrip,$(BR2_PACKAGE_SUMMIT_LINUX_BACKPORTS_CUSTOM_CONFIG_FILE)),)
$(error No linux-backports configuration file specified, check your BR2_PACKAGE_SUMMIT_LINUX_BACKPORTS_CUSTOM_CONFIG_FILE setting)
endif
endif

endif # BR_BUILDING

$(eval $(kernel-module))
$(eval $(kconfig-package))

# linux-backports' own .config file needs options from the kernel's own
# .config file. The dependencies handling in the infrastructure does not
# allow to express this kind of dependencies. Besides, linux.mk might
# not have been parsed yet, so the Linux build dir LINUX_DIR is not yet
# known. Thus, we use a "secondary expansion" so the rule is re-evaluated
# after all Makefiles are parsed, and thus at that time we will have the
# LINUX_DIR variable set to the proper value. Moreover, since linux-4.19,
# the kernel's build system internally touches its .config file, so we
# can't use it as a stamp file. We use the LINUX_KCONFIG_STAMP_DOTCONFIG
# instead.
#
# Furthermore, we want to check the kernel version, since linux-backports
# only supports kernels >= 3.10. To avoid overriding linux-backports'
# KCONFIG_STAMP_DOTCONFIG rule defined in the kconfig-package infra, we
# use an intermediate stamp-file.
#
# Finally, it must also come after the call to kconfig-package, so we get
# SUMMIT_LINUX_BACKPORTS_DIR properly defined (because the target part of the
# rule is not re-evaluated).
#
$(SUMMIT_LINUX_BACKPORTS_DIR)/$(SUMMIT_LINUX_BACKPORTS_KCONFIG_STAMP_DOTCONFIG): $(SUMMIT_LINUX_BACKPORTS_DIR)/.stamp_check_kernel_version

.SECONDEXPANSION:
$(SUMMIT_LINUX_BACKPORTS_DIR)/.stamp_check_kernel_version: $$(LINUX_DIR)/$$(LINUX_KCONFIG_STAMP_DOTCONFIG) | linux
	$(Q)KVER=$(LINUX_VERSION_PROBED); \
	MIN_KVER_MAJOR=$(SUMMIT_LINUX_BACKPORTS_MINIMAL_KVER_MAJOR); \
	MIN_KVER_MINOR=$(SUMMIT_LINUX_BACKPORTS_MINIMAL_KVER_MINOR); \
	KVER_MAJOR=`echo $${KVER} | sed 's/^\([0-9]*\)\..*/\1/'`; \
	KVER_MINOR=`echo $${KVER} | sed 's/^[0-9]*\.\([0-9]*\).*/\1/'`; \
	if [ $${KVER_MAJOR} -lt $(SUMMIT_LINUX_BACKPORTS_MINIMAL_KVER_MAJOR) \
		-o \( $${KVER_MAJOR} -eq $(SUMMIT_LINUX_BACKPORTS_MINIMAL_KVER_MAJOR) \
			-a $${KVER_MINOR} -lt $(SUMMIT_LINUX_BACKPORTS_MINIMAL_KVER_MINOR) \
		\) ]; then \
		printf "Linux version '%s' is too old for linux-backports (needs %s.%s or later)\n" \
			"$${KVER}" \
			"$(SUMMIT_LINUX_BACKPORTS_MINIMAL_KVER_MAJOR)" \
			"$(SUMMIT_LINUX_BACKPORTS_MINIMAL_KVER_MINOR)"; \
		exit 1; \
	fi
	$(Q)touch $(@)

$(SUMMIT_LINUX_BACKPORTS_DIR)/.stamp_built: $$(LINUX_DIR)/.stamp_built | linux
