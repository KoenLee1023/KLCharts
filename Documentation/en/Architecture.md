# KLCharts Architecture

KLCharts shares one data model across two renderers while separating deterministic helpers from SwiftUI drawing.

## Stable renderer slot

`KLDimensionalBarChart` creates both flat and dimensional views in a `ZStack`. The selected mode controls opacity and hit testing. This avoids a different intrinsic layout during transitions and keeps stateful dimensional rendering available between mode changes.

## Flat renderer

Swift Charts owns marks and axes. Package code calculates horizontal canvas width and resolves approximate tap selection by group and series position.

## Dimensional renderer

SwiftUI Canvas projects normalized 3D points into a 2D viewport. Bars, axes, labels, surfaces, and highlights share the projection. Gesture state changes the viewpoint. `resetToken` restores its initial orientation.

## Pure helpers

`KLFlatBarChartLayout` and `KLDimensionalHitTesting` expose behavior that can be verified without mounting a view. Internal perspective geometry follows the same principle but remains implementation detail until a stable public need emerges.

## Host boundary

Business aggregation, localization, themes, legends, navigation, and selected-state storage remain outside. The package receives resolved values so independent features can share rendering without sharing their domain models.

The chart invokes `onSelect` and `onClearSelection` synchronously from interactions. It does not own or mutate the integrating app's selected state. The integrating app decides whether and how to update that state.
