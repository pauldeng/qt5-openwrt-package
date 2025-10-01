# SPDX-License-Identifier: LGPL-3.0-only
# Qt 5.12.12 (qt-everywhere) — Core + Network headless on OpenWrt

include $(TOPDIR)/rules.mk

PKG_NAME:=qt5
PKG_VERSION:=5.12.12
PKG_RELEASE:=1

PKG_SOURCE:=qt-everywhere-src-$(PKG_VERSION).tar.xz
PKG_SOURCE_URL:=https://download.qt.io/archive/qt/5.12/$(PKG_VERSION)/single
# Fill this with the SHA256 that OpenWrt prints on first failed fetch (leave now, fix after first run)
PKG_HASH:=1979a3233f689cb8b3e2783917f8f98f6a2e1821a70815fb737f020cd4b6ab06

PKG_BUILD_DIR:=$(BUILD_DIR)/qt-everywhere-src-$(PKG_VERSION)
PKG_BUILD_PARALLEL:=1
PKG_USE_MIPS16:=0

PKG_LICENSE:=LGPL-3.0-only
PKG_LICENSE_FILES:=LGPL_EXCEPTION.txt LICENSE.LGPLv3

include $(INCLUDE_DIR)/package.mk

# Do NOT sstrip Qt libs (can break .so)
STRIP:=/bin/true
RSTRIP:= \
  NM="$(TOOLCHAIN_DIR)/bin/$(TARGET_CROSS)nm" \
  STRIP="$(STRIP)" \
  STRIP_KMOD="$(STRIP)" \
  $(SCRIPT_DIR)/rstrip.sh

define Package/qt5/Default
  SECTION:=libs
  CATEGORY:=Libraries
  SUBMENU:=Qt5
  TITLE:=Qt5
  URL:=https://www.qt.io
  DEPENDS:=+librt +zlib +libstdcpp +libpthread @!LINUX_2_6
endef

define Package/qt5-core
  $(call Package/qt5/Default)
  TITLE+= core
endef

define Package/qt5-network
  $(call Package/qt5/Default)
  TITLE+= network
  DEPENDS+=+qt5-core
endef

############################################
# Configure
############################################

# Provide a minimal mkspec for cross build
define Build/Configure
	$(INSTALL_DIR) $(PKG_BUILD_DIR)/qtbase/lib/fonts
	$(INSTALL_DIR) $(PKG_BUILD_DIR)/qtbase/mkspecs/linux-openwrt-g++
	$(CP) ./files/fonts/* $(PKG_BUILD_DIR)/qtbase/lib/fonts/ 2>/dev/null || true
	$(CP) ./files/qplatformdefs.h $(PKG_BUILD_DIR)/qtbase/mkspecs/linux-openwrt-g++/qplatformdefs.h
	$(CP) ./files/qmake.conf $(PKG_BUILD_DIR)/qtbase/mkspecs/linux-openwrt-g++/qmake.conf
	$(SED) 's@$(TARGET_CROSS)@$(TARGET_CROSS)@g' $(PKG_BUILD_DIR)/qtbase/mkspecs/linux-openwrt-g++/qmake.conf

	( cd $(PKG_BUILD_DIR) ; \
		TARGET_CC="$(TARGET_CROSS)gcc" \
		TARGET_CXX="$(TARGET_CROSS)g++" \
		TARGET_AR="$(TARGET_CROSS)ar cqs" \
		TARGET_OBJCOPY="$(TARGET_CROSS)objcopy" \
		TARGET_RANLIB="$(TARGET_CROSS)ranlib" \
		TARGET_CFLAGS="$(TARGET_CFLAGS) $(EXTRA_CFLAGS)" \
		TARGET_CXXFLAGS="$(TARGET_CFLAGS) $(EXTRA_CFLAGS)" \
		TARGET_LDFLAGS="$(TARGET_LDFLAGS) $(EXTRA_LDFLAGS) -lpthread -lrt" \
		TARGET_INCDIRS="$(TARGET_INCDIRS)" \
		TARGET_LIBDIRS="$(TARGET_LIBDIRS) $(STAGING_DIR)/usr/lib/" \
		CFLAGS= \
		CXXFLAGS= \
		LDFLAGS= \
		./configure \
			-prefix /usr \
			-extprefix $(TOOLCHAIN_DIR) \
			-sysroot $(TOOLCHAIN_DIR) \
			-xplatform linux-openwrt-g++ \
			-plugindir /usr/lib/Qt/plugins \
			-opensource \
			-confirm-license \
			-optimize-size \
			-strip \
			-no-pch \
			-no-rpath \
			-no-gui \
			-no-dbus \
			-no-opengl \
			-no-eglfs \
			-no-kms \
			-no-openssl \
			-no-feature-ssl \
			-no-directfb \
			-no-xcb \
			-no-cups \
			-no-iconv \
			-no-feature-sql \
			-no-feature-xml \
			-no-feature-testlib \
			-no-feature-ftp \
			-no-feature-networkdiskcache \
			-no-feature-networkproxy \
			-no-feature-action \
			-no-feature-clipboard \
			-no-feature-concurrent \
			-no-feature-cssparser \
			-no-feature-cursor \
			-no-feature-draganddrop \
			-no-feature-effects \
			-no-feature-future \
			-no-feature-highdpiscaling \
			-no-feature-im \
			-no-feature-sessionmanager \
			-no-feature-sharedmemory \
			-no-feature-shortcut \
			-no-feature-tabletevent \
			-no-feature-texthtmlparser \
			-no-feature-textodfwriter \
			-no-feature-wheelevent \
			-no-feature-xmlstream \
			-no-feature-xmlstreamreader \
			-no-feature-xmlstreamwriter \
			-qt-zlib \
			-qt-freetype \
			-nomake examples \
			-nomake tests \
			-skip qt3d \
			-skip qtactiveqt \
			-skip qtandroidextras \
			-skip qtcanvas3d \
			-skip qtcharts \
			-skip qtconnectivity \
			-skip qtdatavis3d \
			-skip qtdeclarative \
			-skip qtdoc \
			-skip qtgamepad \
			-skip qtgraphicaleffects \
			-skip qtimageformats \
			-skip qtlocation \
			-skip qtmacextras \
			-skip qtmultimedia \
			-skip networkauth \
			-skip purchasing \
			-skip qtquickcontrols \
			-skip qtquickcontrols2 \
			-skip qtremoteobjects \
			-skip qtscript \
			-skip qtscxml \
			-skip qtsensors \
			-skip qtserialbus \
			-skip qtspeech \
			-skip qtsvg \
			-skip qttools \
			-skip qttranslations \
			-skip qtvirtualkeyboard \
			-skip qtwayland \
			-skip qtwebchannel \
			-skip qtwebengine \
			-skip qtwebglplugin \
			-skip qtwebsockets \
			-skip websockets \
			-skip qtwebview \
			-skip qtwinextras \
			-skip qtx11extras \
			-skip qtxmlpatterns \
			-v \
	)
endef



############################################
# Compile & Dev install
############################################

define Build/Compile
	$(MAKE) -C $(PKG_BUILD_DIR)
endef

# Optional: install qmake etc. into toolchain host dir if you need them later
define Build/InstallDev
	$(MAKE) -C $(PKG_BUILD_DIR) install
	$(CP) $(PKG_BUILD_DIR)/qtbase/bin/qmake $(TOOLCHAIN_DIR)/bin/
endef

############################################
# Package install (IPK payload)
############################################

define Package/qt5-core/install
	$(INSTALL_DIR) $(1)/usr/lib/
	$(CP) $(PKG_BUILD_DIR)/qtbase/lib/libQt5Core.so* $(1)/usr/lib/
	# If your target needs libatomic at runtime:
	$(CP) $(TOOLCHAIN_DIR)/lib/libatomic.so* $(1)/usr/lib/ 2>/dev/null || true
endef

define Package/qt5-network/install
	$(INSTALL_DIR) $(1)/usr/lib/
	$(CP) $(PKG_BUILD_DIR)/qtbase/lib/libQt5Network.so* $(1)/usr/lib/
endef

$(eval $(call BuildPackage,qt5-core))
$(eval $(call BuildPackage,qt5-network))
