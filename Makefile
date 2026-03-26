DEBUG = 0
FINALPACKAGE = 1
# ターゲットを少し古めに設定すると安定します
TARGET = iphone:clang:14.5:14.0

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = AuthSystem
AuthSystem_FILES = Tweak.x
AuthSystem_CFLAGS = -fobjc-arc
# 依存関係を明示的に指定
AuthSystem_LDFLAGS = -lsubstrate

include $(THEOS)/makefiles/tweak.mk
