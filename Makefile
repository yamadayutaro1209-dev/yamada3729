DEBUG = 0
FINALPACKAGE = 1
# エンジンを中に埋め込む魔法の1行を追加
ARCHS = arm64
TARGET = iphone:clang:latest:14.0

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = AuthSystem
AuthSystem_FILES = Tweak.x
AuthSystem_CFLAGS = -fobjc-arc
# libsubstrateを不要にする設定
AuthSystem_LDFLAGS = -undefined dynamic_lookup

include $(THEOS)/makefiles/tweak.mk
