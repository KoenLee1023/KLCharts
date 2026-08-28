# KLCharts

> <span lang="zh-CN">[English](../../README.md) · [简体中文](../zh-Hans/README.md) · [繁體中文](../zh-Hant/README.md) · [日本語](../ja/README.md) · [한국어](../ko/README.md)</span>

同一组分组数据，两种呈现方式：精确的 Swift Charts 平面图与可探索的立体 Canvas，共用稳定布局。

KLCharts 提供 `.flat` 与 `.dimensional` 两种柱状图渲染器。选择、格式、颜色、业务数据和导航由接入应用拥有。包负责稳定几何、模式切换、命中测试和密集分组的水平扩展。

## 概览

- 平面与投影视图共享数据模型
- 模式切换不替换布局空间
- 接入应用控制选择与清除
- 维度拖动、视点重置与命中测试
- 密集平面图按组宽自动横向滚动

## 要求

- Swift 6.0 或更高版本
- iOS 17 或更高版本
- macOS 14 或更高版本
- 无第三方运行时依赖
- SwiftUI · Swift Charts

## 安装

通过 Xcode 的 Add Package Dependencies 添加仓库，或在 `Package.swift` 中声明：

```swift
dependencies: [
    .package(
        url: "https://github.com/KoenLee1023/KLCharts.git",
        from: "0.1.0"
    )
]
```

```swift
import KLCharts
```

## 快速开始

1. 在接入应用中先解析本地化标签和语义颜色，再构造图表数据。
2. 给图表一个有限高度。它填满父容器提供的槽位。
3. 使用稳定 ID 往返 `selectedID` 与选择回调。
4. 标签拥挤时设置 `flatMinimumGroupWidth`，并为 Canvas 提供完整无障碍说明。

```swift
struct RevenueChart: View {
    @State private var mode = KLDimensionalBarChartMode.flat
    @State private var selectedID: String?
    @State private var resetToken = 0

    let data = [
        KLDimensionalBarDatum(
            id: "jan-online",
            groupKey: "jan",
            groupLabel: "1月",
            seriesKey: "online",
            seriesLabel: "线上",
            value: 42,
            color: .teal
        ),
        KLDimensionalBarDatum(
            id: "jan-store",
            groupKey: "jan",
            groupLabel: "1月",
            seriesKey: "store",
            seriesLabel: "门店",
            value: 28,
            color: .indigo
        )
    ]

    var body: some View {
        KLDimensionalBarChart(
            data: data,
            mode: mode,
            emptyText: "暂无收入数据",
            accessibilityLabel: "按月份和渠道统计的收入",
            selectedID: selectedID,
            resetToken: resetToken,
            flatMinimumGroupWidth: 76,
            axisValueFormatter: { "$\(Int($0))" },
            onSelect: { selectedID = $0.id },
            onClearSelection: { selectedID = nil }
        )
        .frame(height: 300)
    }
}
```

## 行为保证

立体图按照 `groupKey` 和 `seriesKey` 第一次出现的位置排序。平面图按 `groupLabel` 和 `seriesLabel` 定位柱形，但宽度与点击近似计算使用键。每个键必须始终一对一映射到同一个标签，每个 `(groupKey, seriesKey)` 组合也只应出现一次。重复组合会在立体图中重叠，导致点击选择不稳定或被遮挡的柱形无法选中。

图表会同步调用选择回调，但选择状态由接入应用拥有。立体模式中，选中柱形的宽、高、深为 1.06 倍，未选中柱形使用 0.56 透明度。平面模式的未选中柱形使用 0.38 透明度。默认数值 formatter 会把四舍五入后的输入转换为 `Int`，因此该值必须在 `Int` 可表示范围内。NaN、无穷值和超出范围的有限值可能触发运行时错误。自定义 formatter 可以规定其他输入范围。

- `KLDimensionalBarDatum`：稳定的条形、分组和系列身份，加显示标签、数值与颜色。
- `KLDimensionalBarChartMode`：`.flat` 或 `.dimensional`。
- `KLDimensionalBarChart`：两个渲染器保持挂载，通过透明度和命中测试切换。
- `KLFlatBarChartLayout.chartWidth`：无需渲染即可预测横向画布宽度。
- `KLDimensionalHitTesting.acceptsTap`：对有限距离与命中半径执行包含边界的判断。

## 职责边界

只渲染已经解析的数据。不聚合业务模型、不本地化标签、不选主题、不保存选择、不生成图例，也不从柱形触发导航。

## 文档

- [快速开始](GettingStarted.md)
- [API 参考](API.md)
- [架构](Architecture.md)
- [迁移](Migration.md)
- [演示应用](../../Examples/Documentation/zh-Hans/README.md)
- [参与贡献](CONTRIBUTING.md)
- [安全策略](SECURITY.md)
- [行为准则](CODE_OF_CONDUCT.md)
- [变更记录](CHANGELOG.md)

## 状态

该 API 目前处于 1.0 之前。功能已在 wondays 的真实产品场景中使用，但在声明稳定前，小版本仍可能调整命名或策略接口。

## 许可证

MIT. [LICENSE](../../LICENSE)
