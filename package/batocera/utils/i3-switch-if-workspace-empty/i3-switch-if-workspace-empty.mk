################################################################################
#
# i3-switch-if-workspace-empty
#
################################################################################

I3_SWITCH_IF_WORKSPACE_EMPTY_VERSION = 8c033c1a9874e9eb703170e14b6e15fb21da1c3f
I3_SWITCH_IF_WORKSPACE_EMPTY_SITE = $(call github,giuseppe-dandrea,i3-switch-if-workspace-empty,$(I3_SWITCH_IF_WORKSPACE_EMPTY_VERSION))
I3_SWITCH_IF_WORKSPACE_EMPTY_LICENSE = GPL3

define I3_SWITCH_IF_WORKSPACE_EMPTY_INSTALL_TARGET_CMDS
	mkdir -p $(TARGET_DIR)/usr/bin
	$(INSTALL) -D $(@D)/i3-switch-if-workspace-empty $(TARGET_DIR)/usr/bin/i3-switch-if-workspace-empty
endef

$(eval $(generic-package))