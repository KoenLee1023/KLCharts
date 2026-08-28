# KLCharts: 快速开始

> <span lang="zh-CN">[English](../../README.md) · [简体中文](../zh-Hans/README.md) · [繁體中文](../zh-Hant/README.md) · [日本語](../ja/README.md) · [한국어](../ko/README.md)</span>

通过 Xcode 的 Add Package Dependencies 添加仓库，或在 `Package.swift` 中声明：

```swift
dependencies: [
    .package(
        url: "https://github.com/KoenLee1023/KLCharts.git",
        from: "0.1.0"
    )
]
```

KLCharts 支持 iOS 17、macOS 14 和 Swift 6，不含第三方运行时依赖。

## 1. 准备数据

先在接入应用中完成标签本地化和语义颜色选择，再创建图表数据。立体图按照分组键和系列键第一次出现的位置排序。平面图按标签定位柱形，但宽度与点击近似计算使用键，因此每个键必须始终一对一映射到同一个标签。每个 `(groupKey, seriesKey)` 组合只应出现一次。重复组合会让立体柱形重叠，点击结果可能不稳定，被遮挡的柱形也可能无法选中。

```swift
let chartData = records.map { record in
    KLDimensionalBarDatum(
        id: record.id.uuidString,
        groupKey: record.monthKey,
        groupLabel: record.localizedMonth,
        seriesKey: record.category.rawValue,
        seriesLabel: record.category.localizedName,
        value: record.amount,
        color: record.category.color
    )
}
```

ID 应当稳定且唯一，数值应为有限的非负数。KLCharts 不会校验、聚合、排序或归一化输入。

## 2. 管理模式和选择状态

```swift
@State private var mode = KLDimensionalBarChartMode.flat
@State private var selectedID: String?
@State private var resetToken = 0

KLDimensionalBarChart(
    data: chartData,
    mode: mode,
    emptyText: "暂无数据",
    accessibilityLabel: "按月份和渠道统计的收入",
    selectedID: selectedID,
    resetToken: resetToken,
    flatMinimumGroupWidth: 76,
    axisValueFormatter: { $0.formatted(.number.precision(.fractionLength(0))) },
    onSelect: { selectedID = $0.id },
    onClearSelection: { selectedID = nil }
)
.frame(height: 300)
```

图表会同步调用选择与清除回调，但不会拥有或修改 `selectedID`。接入应用决定是否更新状态，并把结果重新传入图表。立体图会把选中柱形的宽、高、深都放大到 1.06 倍，未选中柱形使用 0.56 透明度。平面图的未选中柱形使用 0.38 透明度。两个渲染器始终挂载，隐藏的一侧透明度为零并关闭命中测试。图表会填满并裁切父视图提供的空间，因此必须给它有限高度。

## 3. 重置立体视点

修改 `resetToken` 可以恢复立体图的初始偏航角和俯仰角。平面模式可见时修改也会重置。切换到立体模式时还会再次重置。

```swift
Button("重置视点") {
    resetToken &+= 1
}
```

## 4. 处理密集数据和无障碍

设置 `flatMinimumGroupWidth` 后，平面图会按唯一分组数扩展。只有计算宽度超过容器时才启用横向滚动。有数据的立体图会把 Canvas 作为一个无障碍元素，请提供完整的 `accessibilityLabel`。立体图空状态和平面图使用各自子视图的语义。

`axisValueFormatter` 会由视图保存，并可能在布局与绘制期间多次调用。默认实现会先四舍五入，再转换为 `Int`。四舍五入后的值必须能用 `Int` 表示。NaN、无穷值和超出 `Int` 范围的有限值都可能触发运行时错误。需要其他格式化输入范围时，请提供自定义 formatter。不要在闭包内执行昂贵工作。`showsSeriesLabels` 只控制立体图系列轴标签，不会给平面图添加图例。

## 集成检查

- [ ] ID 稳定且唯一
- [ ] 数值均为有限的非负数
- [ ] 每个键始终一对一映射到同一个标签
- [ ] 不存在重复的 `(groupKey, seriesKey)` 组合
- [ ] 接入应用完成标签本地化和语义颜色选择
- [ ] 图表拥有有限高度
- [ ] 选择状态由接入应用保存并回传
- [ ] 立体模式拥有完整的无障碍说明
