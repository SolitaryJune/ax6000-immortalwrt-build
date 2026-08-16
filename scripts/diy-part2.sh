#!/bin/bash
# diy-part2.sh - 配置后处理 (make defconfig 之前执行)
# 基于 P3TERX/Actions-OpenWrt 模板

# 修改固件命名前缀
sed -i 's|IMG_PREFIX:=|IMG_PREFIX:=$(shell TZ="Asia/Shanghai" date +"%Y%m%d")-AX6000-PW-|' include/image.mk

# 修改版本号
sed -i "s|ImmortalWrt|ImmortalWrt-AX6000-$(TZ="Asia/Shanghai" date +"%Y%m%d")|g" package/base-files/files/bin/config_generate 2>/dev/null || true
