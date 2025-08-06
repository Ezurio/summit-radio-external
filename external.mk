include $(BR2_EXTERNAL_SUMMIT_RADIO_PATH)/versions.mk

SUMMIT_RADIO_STACK_ARCH = $(call qstrip,$(BR2_PACKAGE_SUMMIT_RADIO_STACK_ARCH))

RFPROS_FILESHARE_AUTH ?= $(if $(RFPROS_FILESHARE_USER),$(RFPROS_FILESHARE_USER):$(RFPROS_FILESHARE_PASS)@,)

SUMMIT_RADIO_URI_BASE          = https://github.com/Ezurio/Connectivity_Stack_Release_Packages/releases/download/LRD-REL
SUMMIT_RADIO_URI_BASE_INTERNAL = https://$(RFPROS_FILESHARE_AUTH)files.devops.rfpros.com/builds/linux

ifneq ($(SUMMIT_SOM_URI_BASE_ARCHIVE),)
SUMMIT_RADIO_URI_BASE          = $(SUMMIT_SOM_URI_BASE_ARCHIVE)
endif

include $(sort $(wildcard $(BR2_EXTERNAL_SUMMIT_RADIO_PATH)/package/*/*.mk))
