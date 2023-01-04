################################################################################
#
# i3
#
################################################################################

I3_VERSION = v4.22
I3_SITE = $(call github,i3,I3,$(I3_VERSION))
I3_LICENSE = Apache-2.0
I3_EXTRA_ARGS = 


define I3_BUILD_CMDS
	$(MAKE) $(TARGET_CONFIGURE_OPTS) $(I3_EXTRA_ARGS) -C $(@D)
endef

define I3_INSTALL_TARGET_CMDS
	mkdir -p $(TARGET_DIR)/usr/bin
	$(INSTALL) -D $(@D)/bin/i3 $(TARGET_DIR)/usr/bin/i3
endef

$(eval $(generic-package))
