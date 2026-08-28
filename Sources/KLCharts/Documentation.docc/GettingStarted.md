# Getting Started with KLCharts

Create one data model, provide a finite layout slot, and keep interaction state
in the integrating app.

## Overview

### Add the package

Add `https://github.com/KoenLee1023/KLCharts.git` from version `0.1.0`, link
the `KLCharts` library to a SwiftUI target, and import the module.

```swift
import KLCharts
import SwiftUI
```

KLCharts supports iOS 17 and macOS 14 or later with Swift 6. It has no
third-party runtime dependencies.

### Prepare chart data

Map domain values into ``KLDimensionalBarDatum`` after resolving localized
labels and semantic colors. Dimensional order follows the first occurrence of
each group and series key. Flat marks are positioned by labels, while flat
width and tap approximation use keys. Keep every key mapped to exactly one
consistent label.

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

Use unique, stable IDs and finite, nonnegative values. More than one datum with
the same group and series key occupies the same dimensional position. Overlap
can make the hit result unstable and leave a covered bar unreachable by tap.
The package does not validate, aggregate, sort, or normalize the array.

### Own selection and mode state

``KLDimensionalBarChart`` invokes its interaction callbacks synchronously but
does not own or mutate selection. The integrating app decides whether and how
to update the selected identity and passes that state back into the view.

In dimensional mode, a selected bar scales to `1.06` times its width, height,
and depth, while other bars use `0.56` opacity. In flat mode, other bars use
`0.38` opacity.

```swift
struct RevenueChart: View {
    @State private var mode = KLDimensionalBarChartMode.flat
    @State private var selectedID: String?
    @State private var resetToken = 0

    let data: [KLDimensionalBarDatum]

    var body: some View {
        KLDimensionalBarChart(
            data: data,
            mode: mode,
            emptyText: "No revenue",
            accessibilityLabel: "Revenue by month and channel",
            selectedID: selectedID,
            resetToken: resetToken,
            flatMinimumGroupWidth: 76,
            axisValueFormatter: { value in
                value.formatted(.currency(code: "USD"))
            },
            onSelect: { selectedID = $0.id },
            onClearSelection: { selectedID = nil }
        )
        .frame(height: 300)
    }
}
```

The chart fills and clips its parent slot, so provide a finite height. Both
renderers remain mounted. Mode changes cross-fade them and disable hit testing
on the inactive renderer.

### Reset the dimensional viewpoint

Change `resetToken` whenever the integrating app wants to restore the initial
yaw and pitch.

```swift
Button("Reset view") {
    resetToken &+= 1
}
```

Any token change triggers a reset, including a change made while flat mode is
visible. Entering dimensional mode also resets its viewpoint.

### Support dense data and accessibility

Set `flatMinimumGroupWidth` to widen flat mode by unique group count. Horizontal
scrolling is enabled only when the calculated canvas is wider than its
container. `showsSeriesLabels` affects only dimensional depth-axis labels.

Provide a complete `accessibilityLabel` for a nonempty dimensional chart. Its
Canvas is a single accessibility element. The dimensional empty state and flat
mode use their child views' semantics. Keep `axisValueFormatter` inexpensive
because it is stored by the view and can run repeatedly while either renderer
updates. The default formatter converts the rounded value to `Int`. The rounded
input must fit in `Int`. NaN, infinity, and out-of-range finite values can trap.
A custom formatter may define a different input domain, but it does not make
invalid chart geometry valid.

### Input boundaries

``KLDimensionalHitTesting/acceptsTap(distance:hitRadius:)`` rejects nonfinite
arguments and negative radii, accepts the radius boundary, and does not reject
negative finite distances. ``KLFlatBarChartLayout/chartWidth(availableWidth:groupCount:minimumGroupWidth:)``
uses its inputs directly except that a group count below one is treated as one.
It does not sanitize negative or nonfinite widths.

### Localized guides

- <doc:GettingStarted-zh-Hans>
- <doc:GettingStarted-zh-Hant>
- <doc:GettingStarted-ja>
- <doc:GettingStarted-ko>
