# Copyright (C) 2008 The Android Open Source Project
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

#
# To get your own ICU userdata:
#
# Go to http://apps.icu-project.org/datacustom/ and configure yourself
# a data file.  Unzip the file it gives you, and save that somewhere,
# Set the icu_var_name variable to the location of that file in the tree.
#
# Make sure to choose ICU4C at the bottom.  You should also
# make sure to pick all of the following options, as they are required
# by the system.  Things will fail quietly if you don't have them:
#
# TODO: >>> base list goes here once we have it <<<
#


#
# Common definitions for all variants.
#

LOCAL_PATH:= $(call my-dir)

# Build configuration:
#
# "Large" includes all the supported locales.
# Japanese includes US and Japan.
# US-Euro is needed for IT or PL builds
# Default is suitable for CS, DE, EN, ES, FR, NL
# US has only EN and ES

config := all

include $(LOCAL_PATH)/root.mk

PRODUCT_COPY_FILES += $(LOCAL_PATH)/$(root)-$(config).dat:/system/usr/icu/$(root).dat

ifeq ($(WITH_HOST_DALVIK),true)
    $(eval $(call copy-one-file,$(LOCAL_PATH)/$(root)-$(config).dat,$(HOST_OUT)/usr/icu/$(root).dat))
endif
