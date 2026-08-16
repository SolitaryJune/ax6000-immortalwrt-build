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
