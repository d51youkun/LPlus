TARGET := iphone:clang:latest:18.0
ARCHS := arm64

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = LPlusDiagnostics
LPlusDiagnostics_FILES = Tweak.xm
LPlusDiagnostics_CFLAGS = -fobjc-arc
LPlusDiagnostics_FRAMEWORKS = Foundation UIKit

include $(THEOS_MAKE_PATH)/tweak.mk
