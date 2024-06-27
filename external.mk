include $(BR2_EXTERNAL_SUMMIT_RADIO_PATH)/versions.mk

SUMMIT_RADIO_STACK_ARCH = $(call qstrip,$(BR2_PACKAGE_SUMMIT_RADIO_STACK_ARCH))

RFPROS_FILESHARE_AUTH ?= $(if $(RFPROS_FILESHARE_USER),$(RFPROS_FILESHARE_USER):$(RFPROS_FILESHARE_PASS)@,)

SUMMIT_RADIO_URI_BASE_60       = https://github.com/LairdCP/Sterling-60-Release-Packages/releases/download/LRD-REL
SUMMIT_RADIO_URI_BASE_BDSDMAC  = https://github.com/LairdCP/BDSDMAC-Release-Packages/releases/download/LRD-REL
SUMMIT_RADIO_URI_BASE_LWB      = https://github.com/LairdCP/Sterling-LWB-and-LWB5-Release-Packages/releases/download/LRD-REL
SUMMIT_RADIO_URI_BASE_NX       = https://github.com/LairdCP/SonaNX-Release-Packages/releases/download/LRD-REL
SUMMIT_RADIO_URI_BASE_TI       = https://github.com/LairdCP/SonaTI-Release-Packages/releases/download/LRD-REL
SUMMIT_RADIO_URI_BASE_INTERNAL = https://$(RFPROS_FILESHARE_AUTH)files.devops.rfpros.com/builds/linux

ifeq ($(SUMMIT_SOM_URI_BASE_ARCHIVE),)
SUMMIT_RADIO_URI_BASE_MSD      = https://github.com/LairdCP/Legacy-Release-Packages/releases/download/LRD-REL
else
SUMMIT_RADIO_URI_BASE_MSD      = $(SUMMIT_SOM_ARCHIVE_URI_BASE)
endif

include $(sort $(wildcard $(BR2_EXTERNAL_SUMMIT_RADIO_PATH)/package/*/*.mk))
