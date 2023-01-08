################################################################################
#
# i3-alt-tab
#
################################################################################

I3_ALT_TAB_VERSION =2455ac2db25f98f4dd84142dad5caf3dc432ea97
I3_ALT_TAB_SITE = $(call github,yoshimoto,i3-alt-tab.py,$(I3_ALT_TAB_VERSION))

define I3_ALT_TAB_INSTALL_TARGET_CMDS
	mkdir -p $(TARGET_DIR)/usr/bin
	$(INSTALL) -D $(@D)/i3-alt-tab.py $(TARGET_DIR)/usr/bin/i3-alt-tab.py
endef

$(eval $(generic-package))