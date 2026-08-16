#!/bin/bash
# diy-part1.sh - 编译前准备 (Update feeds 之前执行)
# 基于 P3TERX/Actions-OpenWrt 模板

# 修改默认 LAN IP (可选,默认 192.168.1.1)
# sed -i 's/192.168.1.1/192.168.1.6/g' package/base-files/files/bin/config_generate

# 修改主机名
sed -i 's/ImmortalWrt/AX6000-ImmortalWrt/g' package/base-files/files/bin/config_generate

# 清理 xray-core 等 PassWall 相关旧包(在 feeds 里,避免与 passwall-packages 冲突)
rm -rf feeds/packages/net/{xray-core,v2ray-geodata,sing-box,chinadns-ng,dns2socks,hysteria,ipt2socks,microsocks,naiveproxy,shadowsocks-rust,shadowsocksr-libev,simple-obfs,tcping,v2ray-plugin,xray-plugin,geoview,shadow-tls} 2>/dev/null
rm -rf feeds/luci/applications/luci-app-passwall 2>/dev/null

# 最新 passwall-packages(xray-core 26.x 等)要求 Go >= 1.26,而 24.10 分支 golang 只有 1.23.12
# 升级 golang feed 到 1.26.6(源码包 hash 为 go1.26.6.src 的 sha256)
sed -i 's/GO_VERSION_MAJOR_MINOR:=1.23/GO_VERSION_MAJOR_MINOR:=1.26/' feeds/packages/lang/golang/golang/Makefile
sed -i 's/GO_VERSION_PATCH:=12/GO_VERSION_PATCH:=6/' feeds/packages/lang/golang/golang/Makefile
sed -i 's|PKG_HASH:=e1cce9379a24e895714a412c7ddd157d2614d9edbe83a84449b6e1840b4f1226|PKG_HASH:=a0721c54c688901448d77ad9b3ec7ea7c474730755ff891382e92ecb93ff2cb1|' feeds/packages/lang/golang/golang/Makefile

# Go 1.26 需要 bootstrap >= 1.24.6,feed 自带的 1.20 bootstrap 不够
# 下载预编译 go1.26.6 二进制作为外部 bootstrap(与服务器上验证过的方案一致)
wget -q -O /tmp/go1.26.6.linux-amd64.tar.gz https://dl.google.com/go/go1.26.6.linux-amd64.tar.gz
tar -C /usr/local -xzf /tmp/go1.26.6.linux-amd64.tar.gz
rm -f /tmp/go1.26.6.linux-amd64.tar.gz
/usr/local/go/bin/go version
