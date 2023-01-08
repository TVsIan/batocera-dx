################################################################################
#
# i3
#
################################################################################

I3_VERSION = 4.22
I3_SITE = $(call github,i3,i3,$(I3_VERSION))
I3_LICENSE = BSD-3
I3_EXTRA_ARGS = 

I3_DEPENDENCIES = yajl xcb-util xcb-util-xrm xcb-util-cursor startup-notification

define I3_INSTALL_TARGET_CMDS
	mkdir -p $(TARGET_DIR)/usr/bin
	$(INSTALL) -D $(@D)/build/i3 $(TARGET_DIR)/usr/bin/i3
	$(INSTALL) -D $(@D)/build/i3bar $(TARGET_DIR)/usr/bin/i3bar
	$(INSTALL) -D $(@D)/build/i3-config-wizard $(TARGET_DIR)/usr/bin/i3-config-wizard
	$(INSTALL) -D $(@D)/build/i3-dump-log $(TARGET_DIR)/usr/bin/i3-dump-log
	$(INSTALL) -D $(@D)/build/i3-input $(TARGET_DIR)/usr/bin/i3-input
	$(INSTALL) -D $(@D)/build/i3-msg $(TARGET_DIR)/usr/bin/i3-msg
	$(INSTALL) -D $(@D)/build/i3-nagbar $(TARGET_DIR)/usr/bin/i3-nagbar
	$(INSTALL) -D -m 0755 $(BR2_EXTERNAL_BATOCERA_PATH)/package/batocera/utils/i3/config $(TARGET_DIR)/etc/i3/config
	$(INSTALL) -D -m 0755 $(@D)/etc/config.keycodes $(TARGET_DIR)/etc/i3/config.keycodes
endef

$(eval $(meson-package))