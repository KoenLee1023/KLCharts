# KLCharts

> Language: [English](README.md) · [简体中文](Documentation/zh-Hans/README.md) · [繁體中文](Documentation/zh-Hant/README.md) · [日本語](Documentation/ja/README.md) · [한국어](Documentation/ko/README.md)

API Documentation: [DocC](https://labs.wondays.space/documentation/en/klcharts)

One grouped dataset, two visual grammars: a precise Swift Charts view and an explorable dimensional canvas that occupy the same stable layout.

KLCharts is a SwiftUI package from Nuancery Labs, extracted from production chart behavior in wondays. It keeps geometry and interaction deterministic while leaving business models, localization, themes, and navigation in the host application.

## What is included

- Grouped bar data with independent group and series identity
- A `.flat` renderer built with Swift Charts
- A `.dimensional` renderer built with SwiftUI Canvas
- Stable mode switching inside one layout slot
- Selection and clear-selection callbacks
- Dimensional drag interaction and viewpoint reset
- Host-supplied axis formatting and accessibility text
- Horizontal expansion for dense flat charts
- Public geometry helpers for deterministic tests

## Requirements

- Swift 6.0 or newer
- iOS 17 or newer
- macOS 14 or newer
- SwiftUI and Swift Charts
- No third-party runtime dependencies

## Installation

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

## Quick start

```swift
struct RevenueChart: View {
    @State private var mode = KLDimensionalBarChartMode.flat
    @State private var selectedID: String?
    @State private var resetToken = 0

    let data = [
        KLDimensionalBarDatum(
            id: "jan-online",
            groupKey: "jan",
            groupLabel: "Jan",
            seriesKey: "online",
            seriesLabel: "Online",
            value: 42,
            color: .teal
        ),
        KLDimensionalBarDatum(
            id: "jan-store",
            groupKey: "jan",
            groupLabel: "Jan",
            seriesKey: "store",
            seriesLabel: "Store",
            value: 28,
            color: .indigo
        )
    ]

    var body: some View {
        KLDimensionalBarChart(
            data: data,
            mode: mode,
            emptyText: "No revenue yet",
            accessibilityLabel: "Revenue by month and channel",
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

## Data contract

`id` identifies one bar and must be unique. In dimensional mode, the first occurrence of each `groupKey` and `seriesKey` determines its order. Flat mode positions marks with `groupLabel` and `seriesLabel`, while its width and tap approximation use the keys. Each key must therefore map to exactly one consistent label.

Each `(groupKey, seriesKey)` pair should identify at most one datum. Duplicate pairs overlap in dimensional mode, making tap selection unstable and potentially leaving a covered bar inaccessible. Labels are resolved display strings owned by the integrating app. Colors are semantic SwiftUI values supplied per datum. Keep the array stable when animating updates.

## Interaction model

The flat renderer maps taps to a group and then the nearest series slot. The dimensional renderer projects every bar into screen space and selects within its hit radius. Tapping away invokes `onClearSelection` when supplied.

The chart invokes selection callbacks synchronously. `selectedID` is integrating-app-owned state, and the chart does not mutate it. In dimensional mode, the selected bar scales its width, height, and depth to 1.06 while unselected bars use 0.56 opacity. Flat mode uses 0.38 opacity for unselected bars. Increment `resetToken` to request a dimensional viewpoint reset. Its numeric value has no meaning beyond change detection.

## Layout behavior

Both renderers stay alive in the same `ZStack`. Mode changes use opacity and hit-testing rather than replacing the view tree, preventing surrounding layout from jumping.

The flat chart expands to `groupCount × flatMinimumGroupWidth` when that exceeds available width and becomes horizontally scrollable. Pass `nil` to avoid an explicit minimum. The chart needs a finite height from its container.

## Empty and accessibility states

An empty data array shows `emptyText`. Supply a meaningful `accessibilityLabel` for dimensional mode because the canvas does not inherit the semantic structure available to Swift Charts. `axisValueFormatter` is used by both renderers. Its default implementation rounds each input and converts it to `Int`. The rounded value must be representable by `Int`. NaN, infinity, and finite values outside that range can trap. A custom formatter may define another formatting domain.

## Documentation

- [Getting Started](Documentation/en/GettingStarted.md)
- [API Reference](Documentation/en/API.md)
- [Architecture](Documentation/en/Architecture.md)
- [Migration](Documentation/en/Migration.md)
- [Demo Apps](Examples/Documentation/en/README.md)

## Scope and status

KLCharts does not aggregate domain data, choose colors, localize labels, present legends, store selection, or navigate from a bar. The first implementation is integrated into wondays and remains pre-1.0.

## License

MIT. See [LICENSE](LICENSE).
