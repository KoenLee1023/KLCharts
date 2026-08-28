# KLCharts 演示应用

> [English](../en/README.md) · [简体中文](../zh-Hans/README.md) · [繁體中文](../zh-Hant/README.md) · [日本語](../ja/README.md) · [한국어](../ko/README.md)

两个示例都是独立的 macOS SwiftUI 应用。它们各自包含 `Package.swift` 和应用入口，只依赖本仓库根目录的 KLCharts 软件包，并使用合成数据。

## Geometry Gallery

Geometry Gallery 展示 Q1 到 Q4 四个季度分组，每组包含标签为 Series A 和 Series B 的两个系列。分段选择器用同一组数据在 `.flat` 与 `.dimensional` 之间切换，图表始终占用同一个视图空间。应用提供薄荷色与青色语义颜色，使用默认数值轴 formatter，并设置了无障碍摘要。

这个示例没有配置选择回调、自定义 formatter、密集数据横向滚动、视点重置或空数据状态。

## Interaction Lab

Interaction Lab 只显示 `.dimensional` 模式，使用五个分组和三个系列。副标题显示当前选中数据的 ID。点击命中后，接入应用更新自己管理的选择状态。点击未命中时，清除回调会移除选择。拖动可以改变立体视点，重置按钮通过增加 `resetToken` 恢复初始视点。选中后还可以观察立体图的放大与弱化效果。

这个示例不会切换模式，也不显示平面图、横向滚动、自定义 formatter 或空数据状态。

## 构建

请为两个应用分别使用仓库外可重复使用的构建目录：

```bash
swift build \
  --package-path Examples/GeometryGallery \
  --scratch-path <构建目录>/KLCharts-GeometryGallery

swift build \
  --package-path Examples/InteractionLab \
  --scratch-path <构建目录>/KLCharts-InteractionLab
```
