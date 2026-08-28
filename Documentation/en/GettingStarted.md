# Getting Started with KLCharts

## 1. Add the package

Add `https://github.com/KoenLee1023/KLCharts.git` from `0.1.0`, link `KLCharts`, and import it in a SwiftUI target. The package supports iOS 17, macOS 14, and Swift 6 or later and has no third-party runtime dependencies.

## 2. Adapt domain data once

Resolve localization and semantic colors before creating chart data. Dimensional mode orders groups and series by the first occurrence of each key. Flat mode positions marks by labels, while width and tap approximation use keys. Keep a one-to-one, consistent mapping from every key to its label. Each `(groupKey, seriesKey)` pair should occur once. Duplicate pairs overlap in dimensional mode and can produce unstable or inaccessible tap selection. KLCharts does not validate, aggregate, sort, or normalize the array.

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

## 3. Give the chart a layout slot

```swift
KLDimensionalBarChart(
    data: chartData,
    mode: mode,
    emptyText: "No records"
)
.frame(minHeight: 260, idealHeight: 320)
```

The chart fills available space. An unconstrained vertical parent may not produce the intended result.

## 4. Own interaction state

Pass `selectedID` back with `onSelect` and clear it with `onClearSelection`. The chart invokes both callbacks synchronously but does not own or mutate selection. Do not derive selection from array index because grouping and filtering can change order. In dimensional mode, the selected bar scales its width, height, and depth to 1.06 and other bars use 0.56 opacity. Flat mode uses 0.38 opacity for unselected bars.

Both renderers remain mounted in one layout slot. The inactive renderer has zero opacity and disabled hit testing. Entering dimensional mode resets its viewpoint.

## 5. Tune dense flat layouts

Set `flatMinimumGroupWidth` when labels or grouped bars become compressed. The renderer calculates a wider canvas and enables horizontal scrolling only when needed. A `nil` minimum behaves as zero.

## 6. Format values consistently

Provide one lightweight formatter closure for both visual modes. It is stored with the view and may be called repeatedly. The default formatter rounds its input and converts it to `Int`. The rounded value must be representable by `Int`. NaN, infinity, and out-of-range finite values can trap. Supply a custom formatter if the integrating app needs a different formatting domain. Resolve locale-aware format styles outside hot drawing loops if construction is expensive.

## 7. Reset the dimensional viewpoint

Change `resetToken` to restore the initial yaw and pitch. Any change triggers a reset, even while flat mode is visible. The numeric value itself has no meaning.

## 8. Supply dimensional accessibility text

A nonempty dimensional Canvas is exposed as one accessibility element. Provide a complete `accessibilityLabel`. An empty label falls back to `emptyText`. The dimensional empty state and flat mode use their child views' semantics.

## Integration checklist

- unique stable datum IDs
- finite nonnegative values
- one-to-one key-to-label mappings and stable first-seen dimensional ordering
- no duplicate `(groupKey, seriesKey)` pairs
- localized labels and semantic colors from the host
- finite chart height
- meaningful dimensional accessibility label
- selection state reset when filtered data removes the selected ID
