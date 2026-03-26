DEBUG = 0
FINALPACKAGE = 1
# 警告をエラーとして扱わない設定を追加
GO_EASY_ON_ME = 1

ARCHS = arm64
TARGET = iphone:clang:latest:14.0

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = AuthSystem
AuthSystem_FILES = Tweak.x
AuthSystem_CFLAGS = -fobjc-arc
AuthSystem_LDFLAGS = -undefined dynamic_lookup

include $(THEOS)/makefiles/tweak.mk
