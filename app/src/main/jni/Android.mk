LOCAL_PATH := $(call my-dir)



include $(CLEAR_VARS)
LOCAL_MODULE := GlossHook
LOCAL_SRC_FILES := GlossHook/lib/$(TARGET_ARCH_ABI)/libGlossHook.a
LOCAL_EXPORT_C_INCLUDES := $(LOCAL_PATH)/GlossHook/include/
include $(PREBUILT_STATIC_LIBRARY)

include $(CLEAR_VARS)
LOCAL_MODULE := dobby
LOCAL_SRC_FILES := dobby/libraries/$(TARGET_ARCH_ABI)/libdobby.a
include $(PREBUILT_STATIC_LIBRARY)

# Main library
include $(CLEAR_VARS)

LOCAL_MODULE := libAkAudioVisiual

# -std=c++17 is required to support AIDE app with NDK
LOCAL_CFLAGS := -w -s -Wno-error=format-security -fvisibility=hidden -fpermissive -fexceptions
LOCAL_CPPFLAGS := -w -s -Wno-error=format-security -fvisibility=hidden -Werror -std=c++17
LOCAL_CPPFLAGS += -Wno-error=c++11-narrowing -fpermissive -Wall -fexceptions
LOCAL_CPPFLAGS += -mllvm -sobf -mllvm -bcf_prob=70
LOCAL_CFLAGS += -mllvm -sobf -mllvm -bcf_prob=70
LOCAL_LDFLAGS += -Wl,--gc-sections,--strip-all,-llog
LOCAL_LDLIBS := -llog -landroid -lEGL -lGLESv2
LOCAL_ARM_MODE := arm

LOCAL_C_INCLUDES += $(LOCAL_PATH)
LOCAL_C_INCLUDES += $(LOCAL_PATH)/dobby


LOCAL_SRC_FILES := Main.cpp \
	Substrate/hde64.c \
	Substrate/SubstrateDebug.cpp \
	Substrate/SubstrateHook.cpp \
	Substrate/SubstratePosixMemory.cpp \
	Substrate/SymbolFinder.cpp \
	oxorany/oxorany.cpp \
	KittyMemory/KittyMemory.cpp \
	KittyMemory/MemoryPatch.cpp \
	KittyMemory/MemoryBackup.cpp \
	KittyMemory/KittyUtils.cpp \
	And64InlineHook/And64InlineHook.cpp

LOCAL_STATIC_LIBRARIES := GlossHook dobby

include $(BUILD_SHARED_LIBRARY)