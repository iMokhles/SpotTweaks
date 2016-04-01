GO_EASY_ON_ME = 1

SYSROOT = /opt/theos/sdks/iPhoneOS8.1.sdk
SDKVERSION = 8.1
TARGET_IPHONEOS_DEPLOYMENT_VERSION = 4.3

ADDITIONAL_CFLAGS = -fobjc-arc

ADDITIONAL_LDFLAGS = -Wl,-segalign,4000

THEOS_BUILD_DIR = Packages

include theos/makefiles/common.mk

BUNDLE_NAME = SpotTweaks
SpotTweaks_FILES = Tweak.m XMLReader.m UIAlertView+Blocks.m MALoggingViewController.m SPTWindow.m
SpotTweaks_INSTALL_PATH = /Library/SearchLoader/SearchBundles
SpotTweaks_BUNDLE_EXTENSION = bundle
SpotTweaks_FRAMEWORKS = UIKit Foundation CoreGraphics QuartzCore
SpotTweaks_LDFLAGS = -lspotlight
SpotTweaks_PRIVATE_FRAMEWORKS = Search
SpotTweaks_LIBRARIES = substrate

TWEAK_NAME = SpotTweaksHooks
SpotTweaksHooks_FILES = SpotTweaksHooks.xm UIAlertView+Blocks.m MALoggingViewController.m SPTWindow.m
SpotTweaksHooks_FRAMEWORKS = UIKit Foundation CoreGraphics QuartzCore
SpotTweaksHooks_LIBRARIES = substrate

include $(THEOS_MAKE_PATH)/bundle.mk
include $(THEOS_MAKE_PATH)/tweak.mk

internal-stage::
	sudo mkdir -p $(THEOS_STAGING_DIR)/Library/Application\ Support/SpotTweaks
	sudo mkdir -p $(THEOS_STAGING_DIR)/Library/SearchLoader/
	sudo cp -r InfoBundle/ $(THEOS_STAGING_DIR)/Library/SearchLoader/SpotTweaks.bundle
	sudo cp SpotTweaks.sh $(THEOS_STAGING_DIR)/Library/Application\ Support/SpotTweaks/SpotTweaks.sh

after-install::
	install.exec "killall -9 Cydia search backboardd"
