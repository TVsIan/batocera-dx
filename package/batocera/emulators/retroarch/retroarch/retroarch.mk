################################################################################
#
# retroarch
#
################################################################################

RETROARCH_VERSION = v1.13.0
RETROARCH_SITE = $(call github,libretro,RetroArch,$(RETROARCH_VERSION))
RETROARCH_LICENSE = GPLv3+
RETROARCH_DEPENDENCIES = host-pkgconf dejavu retroarch-assets flac
# install in staging for debugging (gdb)
RETROARCH_INSTALL_STAGING = YES

RETROARCH_CONF_OPTS = --disable-oss --enable-zlib --disable-qt --enable-threads --enable-ozone \
    --enable-xmb --disable-discord --enable-flac --enable-lua --enable-networking \
	--enable-translate --enable-rgui --disable-cdrom

ifeq ($(BR2_ENABLE_DEBUG),y)
    RETROARCH_CONF_OPTS += --enable-debug
endif

ifeq ($(BR2_PACKAGE_FFMPEG),y)
    RETROARCH_CONF_OPTS += --enable-ffmpeg
    RETROARCH_DEPENDENCIES += ffmpeg
else
    RETROARCH_CONF_OPTS += --disable-ffmpeg
endif

ifeq ($(BR2_PACKAGE_SDL2),y)
    RETROARCH_CONF_OPTS += --enable-sdl2
    RETROARCH_DEPENDENCIES += sdl2
else
    RETROARCH_CONF_OPTS += --disable-sdl2
	ifeq ($(BR2_PACKAGE_SDL),y)
        RETROARCH_CONF_OPTS += --enable-sdl
        RETROARCH_DEPENDENCIES += sdl
	else
        RETROARCH_CONF_OPTS += --disable-sdl
	endif
endif

ifeq ($(BR2_PACKAGE_LIBDRM),y)
    RETROARCH_CONF_OPTS += --enable-kms
endif

ifeq ($(BR2_ARM_FPU_NEON_VFPV4)$(BR2_ARM_FPU_NEON)$(BR2_ARM_FPU_NEON_FP_ARMV8),y)
    RETROARCH_CONF_OPTS += --enable-neon
endif

ifeq ($(BR2_GCC_TARGET_FLOAT_ABI),hard)
    RETROARCH_CONF_OPTS += --enable-floathard
endif

# x86 : no option

ifeq ($(BR2_PACKAGE_XSERVER_XORG_SERVER),y)
    RETROARCH_CONF_OPTS += --enable-x11
    RETROARCH_DEPENDENCIES += xserver_xorg-server
else
    RETROARCH_CONF_OPTS += --disable-x11
endif

ifeq ($(BR2_PACKAGE_ALSA_LIB),y)
    RETROARCH_CONF_OPTS += --enable-alsa
    RETROARCH_DEPENDENCIES += alsa-lib
else
    RETROARCH_CONF_OPTS += --disable-alsa
endif

ifeq ($(BR2_PACKAGE_PULSEAUDIO),y)
    RETROARCH_CONF_OPTS += --enable-pulse
    RETROARCH_DEPENDENCIES += pulseaudio
else
    RETROARCH_CONF_OPTS += --disable-pulse
endif

ifeq ($(BR2_PACKAGE_BATOCERA_GLES3),y)
    RETROARCH_CONF_OPTS += --enable-opengles3 --enable-opengles --enable-opengles3_1
    RETROARCH_DEPENDENCIES += libgles
endif
# don't enable --enable-opengles3_2, breaks lr-swanstation

ifeq ($(BR2_PACKAGE_BATOCERA_GLES2),y)
    RETROARCH_CONF_OPTS += --enable-opengles
    RETROARCH_DEPENDENCIES += libgles
endif

ifeq ($(BR2_PACKAGE_HAS_LIBEGL),y)
    RETROARCH_CONF_OPTS += --enable-egl
    RETROARCH_DEPENDENCIES += libegl
else
    RETROARCH_CONF_OPTS += --disable-egl
endif

ifeq ($(BR2_PACKAGE_HAS_LIBOPENVG),y)
    RETROARCH_DEPENDENCIES += libopenvg
endif

ifeq ($(BR2_PACKAGE_ZLIB),y)
    RETROARCH_CONF_OPTS += --enable-zlib
    RETROARCH_DEPENDENCIES += zlib
else
    RETROARCH_CONF_OPTS += --disable-zlib
endif

ifeq ($(BR2_PACKAGE_UDEV),y)
    RETROARCH_DEPENDENCIES += udev
endif

ifeq ($(BR2_PACKAGE_FREETYPE),y)
    RETROARCH_CONF_OPTS += --enable-freetype
    RETROARCH_DEPENDENCIES += freetype
else
    RETROARCH_CONF_OPTS += --disable-freetype
endif

ifeq ($(BR2_PACKAGE_ROCKCHIP_RGA),y)
    RETROARCH_CONF_OPTS += --enable-odroidgo2
    RETROARCH_DEPENDENCIES += rockchip-rga
endif

ifeq ($(BR2_PACKAGE_HAS_LIBGL),y)
  ifneq ($(BR2_PACKAGE_BATOCERA_SBC_XORG)$(BR2_PACKAGE_XWAYLAND),y)
    RETROARCH_CONF_OPTS += --enable-opengl --disable-opengles --disable-opengles3
    RETROARCH_DEPENDENCIES += libgl
  endif
endif

ifeq ($(BR2_PACKAGE_XSERVER_XORG_SERVER),)
	ifeq ($(BR2_PACKAGE_MESA3D_OPENGL_EGL),y)
        RETROARCH_TARGET_CFLAGS += -DEGL_NO_X11
	endif
endif

ifeq ($(BR2_PACKAGE_WAYLAND),y)
    RETROARCH_CONF_OPTS += --enable-wayland
    RETROARCH_DEPENDENCIES += wayland
else
    RETROARCH_CONF_OPTS += --disable-wayland
endif

ifeq ($(BR2_PACKAGE_VULKAN_LOADER)$(BR2_PACKAGE_VULKAN_HEADERS),yy)
    RETROARCH_CONF_OPTS += --enable-vulkan
    RETROARCH_DEPENDENCIES += vulkan-headers vulkan-loader
endif

define RETROARCH_CONFIGURE_CMDS
	(cd $(@D); rm -rf config.cache; \
		$(TARGET_CONFIGURE_ARGS) \
		$(TARGET_CONFIGURE_OPTS) \
		CFLAGS="$(TARGET_CFLAGS) $(RETROARCH_TARGET_CFLAGS)" \
		LDFLAGS="$(TARGET_LDFLAGS) -lc" \
		CROSS_COMPILE="$(HOST_DIR)/usr/bin/" \
		./configure \
		--prefix=/usr \
		$(RETROARCH_CONF_OPTS) \
	)
endef

define RETROARCH_BUILD_CMDS
	$(TARGET_CONFIGURE_OPTS) $(MAKE) CXX="$(TARGET_CXX)" CC="$(TARGET_CC)" LD="$(TARGET_LD)" -C $(@D)/
	$(TARGET_CONFIGURE_OPTS) $(MAKE) CXX="$(TARGET_CXX)" CC="$(TARGET_CC)" LD="$(TARGET_LD)" -C $(@D)/gfx/video_filters
	$(TARGET_CONFIGURE_OPTS) $(MAKE) CXX="$(TARGET_CXX)" CC="$(TARGET_CC)" LD="$(TARGET_LD)" -C $(@D)/libretro-common/audio/dsp_filters
endef

define RETROARCH_INSTALL_TARGET_CMDS
	$(MAKE) CXX="$(TARGET_CXX)" -C $(@D) DESTDIR=$(TARGET_DIR) install

	mkdir -p $(TARGET_DIR)/usr/share/video_filters
	cp $(@D)/gfx/video_filters/*.so $(TARGET_DIR)/usr/share/video_filters
	cp $(@D)/gfx/video_filters/*.filt $(TARGET_DIR)/usr/share/video_filters

	mkdir -p $(TARGET_DIR)/usr/share/audio_filters
	cp $(@D)/libretro-common/audio/dsp_filters/*.so $(TARGET_DIR)/usr/share/audio_filters
	cp $(@D)/libretro-common/audio/dsp_filters/*.dsp $(TARGET_DIR)/usr/share/audio_filters
endef

define RETROARCH_INSTALL_STAGING_CMDS
	$(MAKE) CXX="$(TARGET_CXX)" -C $(@D) DESTDIR=$(STAGING_DIR) install
endef

$(eval $(generic-package))

# DEFINITION OF LIBRETRO PLATFORM
LIBRETRO_PLATFORM = unix

ifeq ($(BR2_arm),y)
    ifeq ($(BR2_cortex_a7),y)
        LIBRETRO_PLATFORM += armv7
    else ifeq ($(BR2_cortex_a9),y)
        LIBRETRO_PLATFORM += armv7
	else ifeq ($(BR2_cortex_a15),y)
        LIBRETRO_PLATFORM += armv7
	else ifeq ($(BR2_cortex_a17),y)
        LIBRETRO_PLATFORM += armv7
	else ifeq ($(BR2_cortex_a53),y)
        LIBRETRO_PLATFORM += armv7
    else ifeq ($(BR2_cortex_a15_a7),y)
        LIBRETRO_PLATFORM += armv7
	endif
endif

ifeq ($(BR2_aarch64),y)
    LIBRETRO_PLATFORM += arm64
endif

ifeq ($(BR2_ARM_CPU_HAS_NEON),y)
    LIBRETRO_PLATFORM += neon
endif

ifeq ($(BR2_PACKAGE_RPI_USERLAND),y)
    LIBRETRO_PLATFORM += rpi armv
endif

ifeq ($(BR2_PACKAGE_BATOCERA_TARGET_BCM2836),y)
    LIBRETRO_PLATFORM += rpi2
endif

ifeq ($(BR2_PACKAGE_BATOCERA_TARGET_BCM2837),y)
    LIBRETRO_PLATFORM += rpi3_64
endif

ifeq ($(BR2_PACKAGE_BATOCERA_TARGET_BCM2711),y)
    LIBRETRO_PLATFORM += rpi4_64
endif

ifeq ($(BR2_PACKAGE_BATOCERA_TARGET_RPIZERO2),y)
    LIBRETRO_PLATFORM += rpi3
endif

# Working around an issue with Retroarch - if Game Focus is set to a controller hotkey, it ignores the hotkey button and toggles every press.
# To fix, using Scroll Lock on Hotkey + R3 on Computer systems.
define RETROARCH_EVMAPY
    mkdir -p $(TARGET_DIR)/usr/share/evmapy
    cp $(BR2_EXTERNAL_BATOCERA_PATH)/package/batocera/emulators/retroarch/retroarch/gamefocus.keys $(TARGET_DIR)/usr/share/evmapy/adam.libretro.keys
    cp $(BR2_EXTERNAL_BATOCERA_PATH)/package/batocera/emulators/retroarch/retroarch/gamefocus.keys $(TARGET_DIR)/usr/share/evmapy/amiga1200.libretro.keys
    cp $(BR2_EXTERNAL_BATOCERA_PATH)/package/batocera/emulators/retroarch/retroarch/gamefocus.keys $(TARGET_DIR)/usr/share/evmapy/amiga500.libretro.keys
    cp $(BR2_EXTERNAL_BATOCERA_PATH)/package/batocera/emulators/retroarch/retroarch/gamefocus.keys $(TARGET_DIR)/usr/share/evmapy/amstradcpc.libretro.keys
    cp $(BR2_EXTERNAL_BATOCERA_PATH)/package/batocera/emulators/retroarch/retroarch/gamefocus.keys $(TARGET_DIR)/usr/share/evmapy/apple2.libretro.keys
    cp $(BR2_EXTERNAL_BATOCERA_PATH)/package/batocera/emulators/retroarch/retroarch/gamefocus.keys $(TARGET_DIR)/usr/share/evmapy/apple2gs.libretro.keys
    cp $(BR2_EXTERNAL_BATOCERA_PATH)/package/batocera/emulators/retroarch/retroarch/gamefocus.keys $(TARGET_DIR)/usr/share/evmapy/archimedes.libretro.keys
    cp $(BR2_EXTERNAL_BATOCERA_PATH)/package/batocera/emulators/retroarch/retroarch/gamefocus.keys $(TARGET_DIR)/usr/share/evmapy/atari800.libretro.keys
    cp $(BR2_EXTERNAL_BATOCERA_PATH)/package/batocera/emulators/retroarch/retroarch/gamefocus.keys $(TARGET_DIR)/usr/share/evmapy/atarist.libretro.keys
    cp $(BR2_EXTERNAL_BATOCERA_PATH)/package/batocera/emulators/retroarch/retroarch/gamefocus.keys $(TARGET_DIR)/usr/share/evmapy/atom.libretro.keys
    cp $(BR2_EXTERNAL_BATOCERA_PATH)/package/batocera/emulators/retroarch/retroarch/gamefocus.keys $(TARGET_DIR)/usr/share/evmapy/bbc.libretro.keys
    cp $(BR2_EXTERNAL_BATOCERA_PATH)/package/batocera/emulators/retroarch/retroarch/gamefocus.keys $(TARGET_DIR)/usr/share/evmapy/c128.libretro.keys
    cp $(BR2_EXTERNAL_BATOCERA_PATH)/package/batocera/emulators/retroarch/retroarch/gamefocus.keys $(TARGET_DIR)/usr/share/evmapy/c20.libretro.keys
    cp $(BR2_EXTERNAL_BATOCERA_PATH)/package/batocera/emulators/retroarch/retroarch/gamefocus.keys $(TARGET_DIR)/usr/share/evmapy/c64.libretro.keys
    cp $(BR2_EXTERNAL_BATOCERA_PATH)/package/batocera/emulators/retroarch/retroarch/gamefocus.keys $(TARGET_DIR)/usr/share/evmapy/camplynx.libretro.keys
    cp $(BR2_EXTERNAL_BATOCERA_PATH)/package/batocera/emulators/retroarch/retroarch/gamefocus.keys $(TARGET_DIR)/usr/share/evmapy/coco.libretro.keys
    cp $(BR2_EXTERNAL_BATOCERA_PATH)/package/batocera/emulators/retroarch/retroarch/gamefocus.keys $(TARGET_DIR)/usr/share/evmapy/cplus4.libretro.keys
    cp $(BR2_EXTERNAL_BATOCERA_PATH)/package/batocera/emulators/retroarch/retroarch/gamefocus.keys $(TARGET_DIR)/usr/share/evmapy/dos.libretro.keys
    cp $(BR2_EXTERNAL_BATOCERA_PATH)/package/batocera/emulators/retroarch/retroarch/gamefocus.keys $(TARGET_DIR)/usr/share/evmapy/electron.libretro.keys
    cp $(BR2_EXTERNAL_BATOCERA_PATH)/package/batocera/emulators/retroarch/retroarch/gamefocus.keys $(TARGET_DIR)/usr/share/evmapy/fm7.libretro.keys
    cp $(BR2_EXTERNAL_BATOCERA_PATH)/package/batocera/emulators/retroarch/retroarch/gamefocus.keys $(TARGET_DIR)/usr/share/evmapy/fmtowns.libretro.keys
    cp $(BR2_EXTERNAL_BATOCERA_PATH)/package/batocera/emulators/retroarch/retroarch/gamefocus.keys $(TARGET_DIR)/usr/share/evmapy/laser310.libretro.keys
    cp $(BR2_EXTERNAL_BATOCERA_PATH)/package/batocera/emulators/retroarch/retroarch/gamefocus.keys $(TARGET_DIR)/usr/share/evmapy/macintosh.libretro.keys
    cp $(BR2_EXTERNAL_BATOCERA_PATH)/package/batocera/emulators/retroarch/retroarch/gamefocus.keys $(TARGET_DIR)/usr/share/evmapy/msx1.libretro.keys
    cp $(BR2_EXTERNAL_BATOCERA_PATH)/package/batocera/emulators/retroarch/retroarch/gamefocus.keys $(TARGET_DIR)/usr/share/evmapy/msx2+.libretro.keys
    cp $(BR2_EXTERNAL_BATOCERA_PATH)/package/batocera/emulators/retroarch/retroarch/gamefocus.keys $(TARGET_DIR)/usr/share/evmapy/msx2.libretro.keys
    cp $(BR2_EXTERNAL_BATOCERA_PATH)/package/batocera/emulators/retroarch/retroarch/gamefocus.keys $(TARGET_DIR)/usr/share/evmapy/msxturbor.libretro.keys
    cp $(BR2_EXTERNAL_BATOCERA_PATH)/package/batocera/emulators/retroarch/retroarch/gamefocus.keys $(TARGET_DIR)/usr/share/evmapy/o2em.libretro.keys
    cp $(BR2_EXTERNAL_BATOCERA_PATH)/package/batocera/emulators/retroarch/retroarch/gamefocus.keys $(TARGET_DIR)/usr/share/evmapy/pc88.libretro.keys
    cp $(BR2_EXTERNAL_BATOCERA_PATH)/package/batocera/emulators/retroarch/retroarch/gamefocus.keys $(TARGET_DIR)/usr/share/evmapy/pc98.libretro.keys
    cp $(BR2_EXTERNAL_BATOCERA_PATH)/package/batocera/emulators/retroarch/retroarch/gamefocus.keys $(TARGET_DIR)/usr/share/evmapy/pdp1.libretro.keys
    cp $(BR2_EXTERNAL_BATOCERA_PATH)/package/batocera/emulators/retroarch/retroarch/gamefocus.keys $(TARGET_DIR)/usr/share/evmapy/pet.libretro.keys
    cp $(BR2_EXTERNAL_BATOCERA_PATH)/package/batocera/emulators/retroarch/retroarch/gamefocus.keys $(TARGET_DIR)/usr/share/evmapy/prboom.libretro.keys
    cp $(BR2_EXTERNAL_BATOCERA_PATH)/package/batocera/emulators/retroarch/retroarch/gamefocus.keys $(TARGET_DIR)/usr/share/evmapy/samcoupe.libretro.keys
    cp $(BR2_EXTERNAL_BATOCERA_PATH)/package/batocera/emulators/retroarch/retroarch/gamefocus.keys $(TARGET_DIR)/usr/share/evmapy/socrates.libretro.keys
    cp $(BR2_EXTERNAL_BATOCERA_PATH)/package/batocera/emulators/retroarch/retroarch/gamefocus.keys $(TARGET_DIR)/usr/share/evmapy/thomson.libretro.keys
    cp $(BR2_EXTERNAL_BATOCERA_PATH)/package/batocera/emulators/retroarch/retroarch/gamefocus.keys $(TARGET_DIR)/usr/share/evmapy/ti99.libretro.keys
    cp $(BR2_EXTERNAL_BATOCERA_PATH)/package/batocera/emulators/retroarch/retroarch/gamefocus.keys $(TARGET_DIR)/usr/share/evmapy/tutor.libretro.keys
    cp $(BR2_EXTERNAL_BATOCERA_PATH)/package/batocera/emulators/retroarch/retroarch/gamefocus.keys $(TARGET_DIR)/usr/share/evmapy/tyrquake.libretro.keys
    cp $(BR2_EXTERNAL_BATOCERA_PATH)/package/batocera/emulators/retroarch/retroarch/gamefocus.keys $(TARGET_DIR)/usr/share/evmapy/x1.libretro.keys
    cp $(BR2_EXTERNAL_BATOCERA_PATH)/package/batocera/emulators/retroarch/retroarch/gamefocus.keys $(TARGET_DIR)/usr/share/evmapy/x68000.libretro.keys
    cp $(BR2_EXTERNAL_BATOCERA_PATH)/package/batocera/emulators/retroarch/retroarch/gamefocus.keys $(TARGET_DIR)/usr/share/evmapy/xegs.libretro.keys
    cp $(BR2_EXTERNAL_BATOCERA_PATH)/package/batocera/emulators/retroarch/retroarch/gamefocus.keys $(TARGET_DIR)/usr/share/evmapy/zx81.libretro.keys
    cp $(BR2_EXTERNAL_BATOCERA_PATH)/package/batocera/emulators/retroarch/retroarch/gamefocus.keys $(TARGET_DIR)/usr/share/evmapy/zxspectrum.libretro.keys
endef

RETROARCH_POST_INSTALL_TARGET_HOOKS += RETROARCH_EVMAPY