# KLCharts API Reference

This document covers every public declaration in KLCharts 0.1.0. Swift-DocC
remains the authority for compiler-derived signatures and symbol relationships.

## `KLDimensionalBarDatum`

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

| Field | Contract |
| --- | --- |
| `id` | Identity used by SwiftUI and `selectedID`. KLCharts does not enforce uniqueness. Duplicate values can select multiple bars and give SwiftUI ambiguous identity. |
| `groupKey` | Nonlocalized grouping identity. First appearance controls dimensional group order and the key participates in flat width and tap approximation. |
| `groupLabel` | Resolved primary-axis text. Swift Charts uses it to position flat marks, so each `groupKey` must map to exactly one consistent label. |
| `seriesKey` | Nonlocalized series identity. First appearance controls dimensional series order and the key participates in flat tap approximation. |
| `seriesLabel` | Resolved series text. Swift Charts uses it to position flat marks, so each `seriesKey` must map to exactly one consistent label. |
| `value` | Bar magnitude. KLCharts performs no validation. The renderers are designed for finite, nonnegative values. |
| `color` | Integrating-app semantic SwiftUI color. Flat mode applies its gradient. Dimensional mode applies selection opacity and face lighting. Dynamic colors resolve in the current environment. |

The initializer stores every argument without validation, sorting, or transformation. Each `(groupKey, seriesKey)` pair should identify at most one datum. Duplicate pairs occupy the same dimensional position, can overlap, and can make tap selection unstable or leave a covered bar inaccessible.

## `KLDimensionalBarChartMode`

```swift
public enum KLDimensionalBarChartMode: String, CaseIterable, Identifiable {
    case flat
    case dimensional
    public var id: String { rawValue }
}
```

- `.flat` displays the Swift Charts renderer.
- `.dimensional` displays the projected SwiftUI Canvas renderer.
- `id` returns the raw value, `"flat"` or `"dimensional"`.

Use these identities for transient UI state. KLCharts does not define a persistence migration policy for them before 1.0.

## `KLDimensionalBarChart`

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

### Parameters

- `data`: Bars rendered by both modes in source order. Empty data displays `emptyText`.
- `mode`: Visible renderer. The inactive renderer remains mounted with zero opacity and disabled hit testing.
- `emptyText`: Host-localized empty-state copy.
- `accessibilityLabel`: Semantic summary applied to a nonempty dimensional chart. An empty string falls back to `emptyText`. The dimensional empty state and flat mode rely on their child views' semantics.
- `selectedID`: Integrating-app-owned selected identity. Unknown IDs match no bar. Duplicate IDs can make multiple bars appear selected. In dimensional mode, the selected bar scales width, height, and depth to 1.06 and unselected bars use 0.56 opacity. Flat mode uses 0.38 opacity for unselected bars. `nil` leaves every bar at normal selection opacity.
- `resetToken`: Any value change resets dimensional yaw and pitch, including changes while flat mode is visible. Entering dimensional mode also resets the viewpoint.
- `showsSeriesLabels`: Controls dimensional depth-axis labels only. It does not add a flat-mode legend.
- `flatMinimumGroupWidth`: Optional minimum width per unique group. `nil` behaves as zero. Flat mode scrolls when the calculated canvas exceeds its container.
- `axisValueFormatter`: Stored closure used for numeric labels in both renderers. It may be called repeatedly during body evaluation and Canvas drawing. The default rounds to the nearest integral value, converts to `Int`, and calls `formatted()`. The rounded input must be representable by `Int`. NaN, infinity, and out-of-range finite values can trap. A custom formatter may define another formatting domain.
- `onSelect`: Stored callback invoked synchronously when a tap resolves to a datum. The chart does not update `selectedID` itself.
- `onClearSelection`: Stored callback invoked synchronously when a tap misses. The chart does not clear `selectedID` itself.

`body` mounts both renderers in one `ZStack`, expands to the parent's available width and height, clips overflow, and cross-fades mode opacity over 0.22 seconds. Flat mode separately animates changes to its array of numeric values over 0.22 seconds. Selection has no explicit package animation. Dimensional viewpoint resets use a 0.26-second snappy animation. Give the chart a finite height. The public view and datum contain SwiftUI values and stored closures and do not conform to `Sendable`. Create and update them in the same UI isolation context as other SwiftUI state.

## `KLFlatBarChartLayout`

```swift
public enum KLFlatBarChartLayout {
    public static func chartWidth(
        availableWidth: CGFloat,
        groupCount: Int,
        minimumGroupWidth: CGFloat
    ) -> CGFloat
}
```

Returns `max(availableWidth, CGFloat(max(groupCount, 1)) * minimumGroupWidth)`. A group count below one is treated as one. No other validation occurs.

- Zero or negative `minimumGroupWidth` participates in the formula unchanged.
- Negative `availableWidth` participates unchanged.
- NaN and positive or negative infinity are passed to Swift's `CGFloat` multiplication and `max` comparison. The result follows those standard operations rather than a KLCharts fallback.

## `KLDimensionalHitTesting`

```swift
public enum KLDimensionalHitTesting {
    public static func acceptsTap(
        distance: CGFloat,
        hitRadius: CGFloat
    ) -> Bool
}
```

Returns `true` exactly when both values are finite, `hitRadius >= 0`, and `distance <= hitRadius`.

- The radius boundary is inclusive.
- Negative, infinite, and NaN radii are rejected.
- Infinite and NaN distances are rejected.
- A finite negative distance is accepted when it is less than or equal to the nonnegative radius. The helper does not normalize distance.

## State ownership example

```swift
@State private var selectedID: String?
@State private var resetToken = 0

KLDimensionalBarChart(
    data: data,
    mode: .dimensional,
    emptyText: "No data",
    selectedID: selectedID,
    resetToken: resetToken,
    onSelect: { selectedID = $0.id },
    onClearSelection: { selectedID = nil }
)

Button("Reset view") {
    resetToken &+= 1
}
```

## Callback and rendering lifetime

The formatter and interaction callbacks are stored in the view value. SwiftUI can recreate that value as state changes, and formatting can run many times per update. Avoid assuming a fixed call count or using these closures as durable storage. Both renderers remain mounted while the chart exists, but only the active renderer accepts hit testing.
