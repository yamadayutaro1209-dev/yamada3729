DEBUG = 0
FINALPACKAGE = 1
TARGET = iphone:clang:latest:14.0

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = AuthSystem
AuthSystem_FILES = Tweak.x
AuthSystem_CFLAGS = -fobjc-arc

include $(THEOS)/makefiles/tweak.mk
