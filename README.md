# Redmi AX6000 ImmortalWrt 定制编译

基于 [padavanonly/immortalwrt-mt798x-6.6](https://github.com/padavanonly/immortalwrt-mt798x-6.6) 官方源码(分支 `openwrt-24.10-6.6`,6.6 内核 + 闭源 MTK 驱动),通过 GitHub Actions 自动编译。

## 固件内容(精简)

- **网络加速**:TurboACC MTK 专用(硬件 NAT / Flow Offload)、`kmod-nf-flow`、`kmod-mediatek_hnat`
- **PassWall**(xray + sing-box 双核心,官方最新源码)
- **mwan3** 多 WAN 负载均衡
- 闭源 MTK WiFi 驱动(MT7986 AX6000)

## 设备

- 小米红米 AX6000:
  - `ubootmod` 布局(OpenWrt U-Boot,当前设备使用)
  - `stock` 布局(原厂)

## 使用

1. Fork 本仓库(或直接使用本仓库的 Releases)
2. 在 Actions 页面手动触发 `Build Redmi AX6000 ImmortalWrt 24.10-6.6` workflow
3. 编译完成后固件自动发布到 Releases,或从 Actions Artifacts 下载

默认 LAN IP:`192.168.1.1`,root 无密码。

## 文件结构

```
.github/workflows/build-ax6000.yml  # GitHub Actions 编译工作流
configs/ax6000.config              # 编译配置(基于官方 defconfig 精简 + PassWall/mwan3)
scripts/diy-part1.sh               # feeds 更新前执行的脚本
scripts/diy-part2.sh               # 配置后处理脚本
```

## 刷机注意

- 刷 `ubootmod` 固件需先刷好 OpenWrt U-Boot
- 刷机前务必备份当前配置
