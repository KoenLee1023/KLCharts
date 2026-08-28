# KLCharts Demo Apps

> [English](../en/README.md) · [简体中文](../zh-Hans/README.md) · [繁體中文](../zh-Hant/README.md) · [日本語](../ja/README.md) · [한국어](../ko/README.md)

Both examples are independent macOS SwiftUI apps. Each has its own `Package.swift` and application entry point, depends only on the repository's root KLCharts package, and uses synthetic data.

## Geometry Gallery

Geometry Gallery renders four quarterly groups, Q1 through Q4, with series labeled Series A and Series B. A segmented picker switches the same dataset between `.flat` and `.dimensional` while keeping the chart in the same frame. The app supplies mint and cyan semantic colors, uses the default numeric axis formatter, and provides an accessibility summary.

This demo does not configure selection callbacks, a custom formatter, dense horizontal scrolling, viewpoint reset, or an empty dataset.

## Interaction Lab

Interaction Lab renders five groups and three series in `.dimensional` mode only. The subtitle shows the selected datum ID. A successful tap updates the integrating app's selection, while a miss invokes the clear callback and removes it. Dragging changes the dimensional viewpoint. The reset button increments `resetToken` to restore the initial viewpoint. Selection also demonstrates the package's dimensional emphasis and dimming.

This demo does not switch modes, render a flat chart, configure horizontal scrolling, supply a custom formatter, or show an empty dataset.

## Build

Build each app with a reusable scratch directory outside the repository:

```bash
swift build \
  --package-path Examples/GeometryGallery \
  --scratch-path <build-directory>/KLCharts-GeometryGallery

swift build \
  --package-path Examples/InteractionLab \
  --scratch-path <build-directory>/KLCharts-InteractionLab
```
