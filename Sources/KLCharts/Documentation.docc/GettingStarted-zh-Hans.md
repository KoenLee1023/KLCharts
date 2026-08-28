# 使用 KLCharts

用一套数据切换 Swift Charts 平面图和可旋转的 Canvas 立体图，并由接入应用管理交互状态。

## 概览

### 添加软件包

从 `0.1.0` 起添加 `https://github.com/KoenLee1023/KLCharts.git`，将 `KLCharts` 链接到 SwiftUI target，然后导入模块。

```swift
import KLCharts
import SwiftUI
```

KLCharts 支持 iOS 17、macOS 14 和 Swift 6，不含第三方运行时依赖。

### 准备数据

先在接入应用中完成标签本地化和语义颜色选择，再创建 ``KLDimensionalBarDatum``。立体图顺序由每个 `groupKey` 和 `seriesKey` 第一次出现的位置决定。平面图按标签定位柱形，但宽度和点击近似计算仍使用键。每个键必须始终对应唯一标签。

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

每个 ID 应当稳定且唯一，数值应为有限的非负数。相同 `(groupKey, seriesKey)` 的多条数据会占用同一个立体位置。重叠可能让命中结果不稳定，也可能让被遮挡的柱形无法通过点击选中。软件包不会校验、聚合、排序或归一化输入。

### 管理模式和选择状态

``KLDimensionalBarChart`` 会同步调用交互回调，但不拥有也不修改选择状态。接入应用自行决定是否更新以及如何更新，再把选择结果传回 `selectedID`。

立体模式会把选中柱形的宽度、高度和深度放大到 `1.06` 倍，其他柱形使用 `0.56` 透明度。平面模式中其他柱形使用 `0.38` 透明度。

```swift
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

图表会填满父视图提供的空间并裁切越界内容，因此需要给它有限高度。两个渲染器始终挂载。切换模式时只改变透明度和命中测试，并执行 0.22 秒的交叉淡入淡出。

### 重置立体视点

修改 `resetToken` 可以恢复立体图的初始偏航角和俯仰角。即使当前显示平面图，token 的变化也会触发重置。切换到立体模式时还会再次重置。

```swift
Button("重置视点") {
    resetToken &+= 1
}
```

### 密集数据、格式和无障碍

`flatMinimumGroupWidth` 按唯一分组数计算平面图画布宽度。画布超过容器后才启用横向滚动。`showsSeriesLabels` 只控制立体图的系列轴标签，不会给平面图添加图例。

有数据的立体图会把 Canvas 作为一个无障碍元素呈现，请提供完整的 `accessibilityLabel`。立体图空状态和平面图使用各自子视图提供的语义。`axisValueFormatter` 会被视图保存，并可能在布局和绘制期间多次调用，不应在闭包中执行昂贵工作。默认 formatter 会把舍入结果转换为 `Int`。该结果必须能由 `Int` 表示，NaN、无穷值和超出 `Int` 范围的有限值可能触发运行时陷阱。自定义 formatter 可以定义其他输入范围，但不会修复无效的图表几何。

### 输入边界

``KLDimensionalHitTesting/acceptsTap(distance:hitRadius:)`` 会拒绝非有限值和负半径，半径边界算作命中。函数不会拒绝有限的负距离。``KLFlatBarChartLayout/chartWidth(availableWidth:groupCount:minimumGroupWidth:)`` 只会把小于 1 的分组数按 1 处理，不会清洗负宽度、NaN 或无穷值。
