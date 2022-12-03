################################################################################
#
# mGBA
#
################################################################################

MGBA_VERSION = 0.10.0
MGBA_SITE = https://github.com/mgba-emu/mgba.git
MGBA_SITE_METHOD=git
MGBA_GIT_SUBMODULES=YES
MGBA_LICENSE = MPLv2
MGBA_DEPENDENCIES = ffmpeg libzip qt5base sdl2 libedit

MGBA_CONF_OPTS  = -DCMAKE_BUILD_TYPE=Release
MGBA_CONF_OPTS += -DUSE_LUA=OFF
MGBA_CONF_OPTS += -DENABLE_SCRIPTING=OFF
MGBA_CONF_OPTS += -DUSE_DISCORD_RPC=OFF
MGBA_CONF_OPTS += -DBUILD_LIBRETRO=OFF

# Building/installing both SDL (command line) and QT (GUI) versions at the moment
# Will likely remove one based on testing.
define MGBA_INSTALL_TARGET_CMDS
	$(INSTALL) -D $(@D)/sdl/mgba $(TARGET_DIR)/usr/bin/mgba
    $(INSTALL) -D $(@D)/qt/mgba-qt $(TARGET_DIR)/usr/bin/mgba-qt
endef

define MGBA_POST_PROCESS
	mkdir -p $(TARGET_DIR)/usr/share/evmapy
	cp $(BR2_EXTERNAL_BATOCERA_PATH)/package/batocera/emulators/mgba/mgba.keys $(TARGET_DIR)/usr/share/evmapy
endef

MGBA_POST_INSTALL_TARGET_HOOKS += MGBA_POST_PROCESS

$(eval $(cmake-package))
