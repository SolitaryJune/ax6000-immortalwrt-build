#!/bin/bash
# diy-part2.sh - 配置后处理 (feeds install 之后、make defconfig 之前执行)
# 基于 P3TERX/Actions-OpenWrt 模板

# 修改固件命名前缀
sed -i 's|IMG_PREFIX:=|IMG_PREFIX:=$(shell TZ="Asia/Shanghai" date +"%Y%m%d")-AX6000-PW-|' include/image.mk

# 修改版本号
sed -i "s|ImmortalWrt|ImmortalWrt-AX6000-$(TZ="Asia/Shanghai" date +"%Y%m%d")|g" package/base-files/files/bin/config_generate 2>/dev/null || true

# ---- PassWall Go 1.26 修复 ----
# 最新 passwall-packages(xray-core 26.x 等)要求 Go >= 1.26,而 24.10 分支 golang feed 只有 1.23.12
# 此脚本在 feeds install 之后执行,feeds/packages/lang/golang/ 已存在
GOLANG_MK=feeds/packages/lang/golang/golang/Makefile

# 1) 升级 golang feed 到 1.26.6(源码包 hash 为 go1.26.6.src.tar.gz 官方 sha256)
sed -i 's/GO_VERSION_MAJOR_MINOR:=1.23/GO_VERSION_MAJOR_MINOR:=1.26/' $GOLANG_MK
sed -i 's/GO_VERSION_PATCH:=12/GO_VERSION_PATCH:=6/' $GOLANG_MK
sed -i 's|PKG_HASH:=e1cce9379a24e895714a412c7ddd157d2614d9edbe83a84449b6e1840b4f1226|PKG_HASH:=a0721c54c688901448d77ad9b3ec7ea7c474730755ff891382e92ecb93ff2cb1|' $GOLANG_MK

# 2) 下载预编译 go1.26.6 到 /opt/go 作为外部 bootstrap
#    (不用 /usr/local/go:GitHub runner 已预装 Go 占用该目录且无写权限)
if [ ! -x /opt/go/bin/go ]; then
  sudo mkdir -p /opt/go
  sudo chown $USER:$GROUPS /opt/go
  wget -q -O /tmp/go1.26.6.linux-amd64.tar.gz https://dl.google.com/go/go1.26.6.linux-amd64.tar.gz
  tar -C /opt/go --strip-components=1 -xzf /tmp/go1.26.6.linux-amd64.tar.gz
  rm -f /tmp/go1.26.6.linux-amd64.tar.gz
fi
/opt/go/bin/go version

# 3) 关键修复:go1.26.6 编译要求 bootstrap >= 1.24.6,feed 引导链最高只能产 go1.20
#    → 让最终编译直接用外部 go 做 bootstrap(替换 1.20 引导步骤)
sed -i 's|GOROOT_BOOTSTRAP="\$(BOOTSTRAP_1_20_BUILD_DIR)"|GOROOT_BOOTSTRAP="\$(BOOTSTRAP_ROOT_DIR)"|' $GOLANG_MK
grep -n 'GOROOT_BOOTSTRAP=' $GOLANG_MK

# 4) 配置外部 bootstrap(写入 .config,make defconfig 会保留显式设置)
sed -i '/CONFIG_GOLANG_EXTERNAL_BOOTSTRAP_ROOT/d' .config
echo 'CONFIG_GOLANG_EXTERNAL_BOOTSTRAP_ROOT="/opt/go"' >> .config

# 5) Go modules 走国内镜像:proxy.golang.org 常被墙/IPv6 超时导致下载失败
#    (goproxy.cn 走 IPv4,实测可用;direct 兜底直连)
#    GitHub Actions 每个 step 是独立 shell,必须写入 $GITHUB_ENV 才能让后续
#    make download / 编译 step 生效;本地构建则直接 export
if [ -n "$GITHUB_ENV" ]; then
  echo 'GOPROXY=https://goproxy.cn,direct' >> $GITHUB_ENV
  echo 'GOSUMDB=sum.golang.google.cn' >> $GITHUB_ENV
else
  export GOPROXY=https://goproxy.cn,direct
  export GOSUMDB=sum.golang.google.cn
fi
