# KLCharts API 参考

> <span lang="zh-CN">[English](../../README.md) · [简体中文](../zh-Hans/README.md) · [繁體中文](../zh-Hant/README.md) · [日本語](../ja/README.md) · [한국어](../ko/README.md)</span>

KLCharts 提供 `.flat` 与 `.dimensional` 两种柱状图渲染器。选择、格式、颜色、业务数据和导航由接入应用拥有。包负责稳定几何、模式切换、命中测试和密集分组的水平扩展。

## 公开 API

- `KLDimensionalBarDatum`：稳定的条形、分组和系列身份，加显示标签、数值与颜色。
- `KLDimensionalBarChartMode`：`.flat` 或 `.dimensional`。
- `KLDimensionalBarChart`：两个渲染器保持挂载，通过透明度和命中测试切换。
- `KLFlatBarChartLayout.chartWidth`：无需渲染即可预测横向画布宽度。
- `KLDimensionalHitTesting.acceptsTap`：对有限距离与命中半径执行包含边界的判断。

## 完整签名

```swift
public struct KLDimensionalBarDatum: Identifiable {
    public let id: String
    public let groupKey: String
    public let groupLabel: String
    public let seriesKey: String
    public let seriesLabel: String
    public let value: Double
    public let color: Color

    public init(
        id: String,
        groupKey: String,
        groupLabel: String,
        seriesKey: String,
        seriesLabel: String,
        value: Double,
        color: Color
    )
}
```

```swift
public enum KLDimensionalBarChartMode: String, CaseIterable, Identifiable {
    case flat
    case dimensional
    public var id: String { rawValue }
}
```

```swift
public struct KLDimensionalBarChart: View {
    public init(
        data: [KLDimensionalBarDatum],
        mode: KLDimensionalBarChartMode,
        emptyText: String,
        accessibilityLabel: String = "",
        selectedID: String? = nil,
        resetToken: Int = 0,
        showsSeriesLabels: Bool = true,
        flatMinimumGroupWidth: CGFloat? = nil,
        axisValueFormatter: @escaping (Double) -> String = {
            Int($0.rounded()).formatted()
        },
        onSelect: ((KLDimensionalBarDatum) -> Void)? = nil,
        onClearSelection: (() -> Void)? = nil
    )
}
```

```swift
public enum KLFlatBarChartLayout {
    public static func chartWidth(
        availableWidth: CGFloat,
        groupCount: Int,
        minimumGroupWidth: CGFloat
    ) -> CGFloat
}
```

```swift
public enum KLDimensionalHitTesting {
    public static func acceptsTap(
        distance: CGFloat,
        hitRadius: CGFloat
    ) -> Bool
}
```

```swift
@State private var selectedID: String?
@State private var resetToken = 0

KLDimensionalBarChart(
    data: data,
    mode: .dimensional,
    emptyText: "暂无数据",
    selectedID: selectedID,
    resetToken: resetToken,
    onSelect: { selectedID = $0.id },
    onClearSelection: { selectedID = nil }
)

Button("重置视点") {
    resetToken &+= 1
}
```

## 数据契约

- `id` 用于 SwiftUI 身份和 `selectedID` 匹配。软件包不检查唯一性。重复 ID 可能让多个柱形同时呈现选中状态，也会给 SwiftUI 带来不明确的身份。
- `groupKey` 和 `seriesKey` 是不应本地化的业务身份。立体图按照各键在数组中第一次出现的位置排列分组和系列。平面图的宽度与点击近似计算也使用这些键。
- `groupLabel` 和 `seriesLabel` 会直接显示，不会由软件包翻译。Swift Charts 使用标签定位平面图中的柱形，因此每个键必须始终一对一映射到同一个标签。
- `value` 不经过校验。两个渲染器都按有限的非负数设计，负数或非有限值可能生成无意义或依赖框架实现的结果。
- `color` 是接入应用提供的 SwiftUI 语义颜色。平面图使用其渐变，立体图在它上面叠加选择透明度和表面明暗。动态颜色会按当前环境解析。

初始化器只保存参数，不会校验、排序或转换。每个 `(groupKey, seriesKey)` 组合最多应对应一条数据。重复组合会在立体图中占据同一位置，柱形相互遮挡，点击选择也可能不稳定，甚至无法选中被盖住的柱形。

## 模式契约

- `.flat` 显示 Swift Charts 平面图。
- `.dimensional` 显示 SwiftUI Canvas 立体图。
- `id` 返回原始字符串 `"flat"` 或 `"dimensional"`。1.0 之前不应把这些值当作拥有迁移保证的长期存储格式。

## 图表属性和初始化参数

- `data` 按原数组顺序交给两个渲染器。空数组显示 `emptyText`。
- `mode` 决定可见且可接收点击的渲染器。另一个渲染器仍然挂载，只是透明度为零并关闭命中测试。
- `emptyText` 由接入应用完成本地化。
- `accessibilityLabel` 用于有数据的立体图。空字符串会回退到 `emptyText`。立体图空状态和平面模式使用各自子视图提供的无障碍语义。
- `selectedID` 由接入应用管理。未知 ID 不会匹配任何柱形，重复 ID 可能同时选中多个柱形。立体图会把选中柱形的宽、高、深都放大到 1.06 倍，未选中柱形使用 0.56 透明度。平面图的未选中柱形使用 0.38 透明度。`nil` 表示不应用选择效果。
- `resetToken` 的任何变化都会恢复立体图的初始视点，平面模式可见时也一样。切换到立体模式时还会重置一次。
- `showsSeriesLabels` 只控制立体图系列轴标签，不会给平面图增加图例。
- `flatMinimumGroupWidth` 是平面模式每个唯一分组的最小宽度。`nil` 按零处理。计算结果超过容器后才启用横向滚动。
- `axisValueFormatter` 会被视图保存，并用于两个渲染器的数值标签。它可能在布局和 Canvas 绘制中多次调用。默认实现先四舍五入，再转换为 `Int` 并调用 `formatted()`。四舍五入后的值必须能用 `Int` 表示。NaN、无穷值和超出 `Int` 范围的有限值都可能触发运行时错误。自定义 formatter 可以规定其他格式化输入范围。
- `onSelect` 在点击命中数据时同步调用。`onClearSelection` 在点击未命中时同步调用。两个闭包都会被视图保存，图表本身不会修改选择状态。
- `body` 把两个渲染器放在同一个 `ZStack` 中，填满父视图提供的宽高并裁切越界内容。模式透明度使用 0.22 秒缓动动画。接入应用需要提供有限高度。

公开视图和数据类型包含 SwiftUI 值与闭包，没有声明 `Sendable`。应当和其他 SwiftUI 状态放在相同的 UI 隔离上下文中创建和更新。

## 布局函数的精确行为

`chartWidth` 返回 `max(availableWidth, CGFloat(max(groupCount, 1)) * minimumGroupWidth)`。

- 小于 1 的 `groupCount` 按 1 计算。
- 零或负的 `minimumGroupWidth` 会原样参与公式。
- 负的 `availableWidth` 也会原样参与公式。
- NaN 和正负无穷值不会被清洗，结果遵循 Swift 的 `CGFloat` 乘法与 `max` 比较。

## 命中函数的精确行为

`acceptsTap` 只有在两个参数均为有限值、`hitRadius >= 0` 且 `distance <= hitRadius` 时返回 `true`。

- 等于半径的边界会命中。
- 负半径、NaN 和正负无穷半径会被拒绝。
- NaN 和正负无穷距离会被拒绝。
- 有限的负距离只要小于等于非负半径就会被接受。函数不会把距离归一化。

## 行为保证

- 平面与投影视图共享数据模型
- 模式切换不替换布局空间
- 接入应用控制选择与清除
- 维度拖动、视点重置与命中测试
- 密集平面图按组宽自动横向滚动

## 职责边界

只渲染已经解析的数据。不聚合业务模型、不本地化标签、不选主题、不保存选择、不生成图例，也不从柱形触发导航。
