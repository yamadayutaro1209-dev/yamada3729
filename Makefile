DEBUG = 0
FINALPACKAGE = 1
ARCHS = arm64
# 依存関係を完全に切り離す魔法のオプション
TARGET = iphone:clang:latest:14.0

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = AuthSystem
AuthSystem_FILES = Tweak.x
AuthSystem_CFLAGS = -fobjc-arc
# ここで外部ライブラリとの接続を「リンクしない」設定にします
AuthSystem_LDFLAGS = -undefined dynamic_lookup

include $(THEOS)/makefiles/tweak.mk
