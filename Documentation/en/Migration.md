# Migrating to KLCharts

## 1. Freeze visible behavior

Record group order, series order, colors, labels, axis formatting, empty text, selected-state appearance, minimum width, and reset behavior before replacing a chart.

## 2. Create a domain adapter

Map existing models to `KLDimensionalBarDatum` at the feature boundary. Keep IDs stable and preserve the current array ordering.

## 3. Move state ownership to the host

Retain selected ID and mode in existing view state. Wire callbacks without changing navigation or detail presentation.

```swift
KLDimensionalBarChart(
    data: adapter.data,
    mode: packageMode,
    emptyText: strings.empty,
    selectedID: selectedID,
    onSelect: { selectedID = $0.id },
    onClearSelection: { selectedID = nil }
)
```

## 4. Preserve theme and localization

Pass resolved colors, labels, empty copy, accessibility text, and formatters. KLCharts must not become a second owner of product design tokens or locale resources.

## 5. Remove duplicate rendering

Move deterministic geometry tests to the public helpers first. Delete local flat and perspective renderers only after package tests and integrating-app visual regression tests pass in both modes.
