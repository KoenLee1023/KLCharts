# ``KLCharts``

Render one grouped dataset as a Swift Charts bar chart or an interactive
projected Canvas without changing its layout slot.

KLCharts leaves data aggregation, localization, semantic colors, selection
state, and navigation to the integrating app. The package owns rendering,
mode transitions, dimensional viewpoint interaction, hit testing, and optional
horizontal expansion for dense flat charts.

## Topics

### Essentials

- <doc:GettingStarted>
- ``KLDimensionalBarChart``
- ``KLDimensionalBarDatum``

### Chart Configuration

- ``KLDimensionalBarChartMode``
- ``KLDimensionalBarChart/data``
- ``KLDimensionalBarChart/mode``
- ``KLDimensionalBarChart/emptyText``
- ``KLDimensionalBarChart/accessibilityLabel``
- ``KLDimensionalBarChart/selectedID``
- ``KLDimensionalBarChart/resetToken``
- ``KLDimensionalBarChart/showsSeriesLabels``
- ``KLDimensionalBarChart/flatMinimumGroupWidth``
- ``KLDimensionalBarChart/axisValueFormatter``
- ``KLDimensionalBarChart/onSelect``
- ``KLDimensionalBarChart/onClearSelection``
- ``KLDimensionalBarChart/init(data:mode:emptyText:accessibilityLabel:selectedID:resetToken:showsSeriesLabels:flatMinimumGroupWidth:axisValueFormatter:onSelect:onClearSelection:)``
- ``KLDimensionalBarChart/body``

### Datum Fields

- ``KLDimensionalBarDatum/id``
- ``KLDimensionalBarDatum/groupKey``
- ``KLDimensionalBarDatum/groupLabel``
- ``KLDimensionalBarDatum/seriesKey``
- ``KLDimensionalBarDatum/seriesLabel``
- ``KLDimensionalBarDatum/value``
- ``KLDimensionalBarDatum/color``
- ``KLDimensionalBarDatum/init(id:groupKey:groupLabel:seriesKey:seriesLabel:value:color:)``

### Modes

- ``KLDimensionalBarChartMode/flat``
- ``KLDimensionalBarChartMode/dimensional``
- ``KLDimensionalBarChartMode/id``
- ``KLDimensionalBarChartMode/init(rawValue:)``

### Deterministic Helpers

- ``KLFlatBarChartLayout``
- ``KLFlatBarChartLayout/chartWidth(availableWidth:groupCount:minimumGroupWidth:)``
- ``KLDimensionalHitTesting``
- ``KLDimensionalHitTesting/acceptsTap(distance:hitRadius:)``
