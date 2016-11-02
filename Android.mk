LOCAL_PATH := $(call my-dir)

include $(CLEAR_VARS)
LOCAL_MODULE := dirtycow
LOCAL_SRC_FILES := \
	dirtycow.c
LOCAL_CFLAGS += -DDEBUG
LOCAL_SHARED_LIBRARIES := liblog
LOCAL_SDK_VERSION := 21
include $(BUILD_EXECUTABLE)

include $(CLEAR_VARS)
LOCAL_MODULE := root-app_process64
LOCAL_SRC_FILES := \
	root-app_process64.c
LOCAL_CFLAGS += -DDEBUG -Os
LOCAL_SHARED_LIBRARIES := liblog libcutils libselinux
include $(BUILD_EXECUTABLE)

include $(CLEAR_VARS)
LOCAL_MODULE := root-run-as
LOCAL_SRC_FILES := \
	root-run-as.c
LOCAL_CFLAGS += -Os
LOCAL_SHARED_LIBRARIES := libselinux
include $(BUILD_EXECUTABLE)
