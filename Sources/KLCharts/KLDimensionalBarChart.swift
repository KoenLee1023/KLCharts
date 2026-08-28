import SwiftUI

/// A value that describes one bar in both KLCharts renderers.
///
/// Dimensional mode derives group and series order from the first occurrence
/// of each ``groupKey`` and ``seriesKey``. Flat mode asks Swift Charts to
/// position marks by ``groupLabel`` and ``seriesLabel``, while its width and
/// tap approximation still use the keys. Keep each key in a one-to-one,
/// consistent relationship with its label across the array.
///
/// KLCharts does not sort, aggregate, normalize, or validate data. More than
/// one datum with the same `(groupKey, seriesKey)` occupies the same
/// dimensional x/z position and can overlap. That overlap can make selection
/// unstable and can leave a covered bar inaccessible by tapping. Supply a
/// stable, unique ``id`` for each bar and resolve display labels and semantic
/// colors in the integrating app.
public struct KLDimensionalBarDatum: Identifiable {
    /// The identity used by SwiftUI and by ``KLDimensionalBarChart/selectedID``.
    ///
    /// KLCharts does not enforce uniqueness. Reusing an identifier can make
    /// multiple bars appear selected and gives SwiftUI ambiguous identity.
    public let id: String

    /// The nonlocalized identity of the primary-axis group.
    ///
    /// The first occurrence of each distinct key determines dimensional group
    /// order and flat width and tap calculations. Keep one consistent
    /// ``groupLabel`` for each key because flat marks are positioned by label.
    public let groupKey: String

    /// The display label for the primary-axis group.
    ///
    /// KLCharts displays this string as supplied and does not localize it. Flat
    /// mode positions marks by this label rather than ``groupKey``. Use a
    /// one-to-one mapping between group keys and labels.
    public let groupLabel: String

    /// The nonlocalized identity of the series within a group.
    ///
    /// The first occurrence of each distinct key determines dimensional series
    /// order and flat tap calculations. Keep one consistent ``seriesLabel``
    /// for each key because flat marks are positioned by label.
    public let seriesKey: String

    /// The display label for the series.
    ///
    /// Flat mode uses the label to position grouped marks rather than
    /// ``seriesKey``. Dimensional mode uses the first label found for each key
    /// as a depth-axis label when
    /// ``KLDimensionalBarChart/showsSeriesLabels`` is `true`.
    public let seriesLabel: String

    /// The magnitude passed to the active renderer.
    ///
    /// The package does not reject negative or nonfinite values. Both
    /// renderers are designed for finite, nonnegative values, and other input
    /// can produce framework-dependent or nonmeaningful geometry.
    public let value: Double

    /// The semantic SwiftUI color used to render the bar.
    ///
    /// The flat renderer applies the color's gradient. The dimensional
    /// renderer applies selection opacity and face lighting to the supplied
    /// color. Dynamic colors continue to resolve in the current environment.
    public let color: Color

    /// Creates a bar datum without validating or transforming its fields.
    ///
    /// - Parameters:
    ///   - id: A stable, unique identity for this bar.
    ///   - groupKey: The nonlocalized group identity. First occurrence controls
    ///     dimensional-mode group order and flat-mode width and tap mapping.
    ///   - groupLabel: Resolved display text used by Swift Charts to position
    ///     flat-mode groups.
    ///   - seriesKey: The nonlocalized series identity. First occurrence
    ///     controls dimensional-mode series order and flat-mode tap mapping.
    ///   - seriesLabel: Resolved display text used by Swift Charts to position
    ///     flat-mode series.
    ///   - value: The bar magnitude. Finite, nonnegative values form the
    ///     intended geometry domain. With the default axis formatter, every
    ///     rounded label value must also be representable by `Int`.
    ///   - color: A semantic SwiftUI color supplied by the integrating app.
    public init(
        id: String,
        groupKey: String,
        groupLabel: String,
        seriesKey: String,
        seriesLabel: String,
        value: Double,
        color: Color
    ) {
        self.id = id
        self.groupKey = groupKey
        self.groupLabel = groupLabel
        self.seriesKey = seriesKey
        self.seriesLabel = seriesLabel
        self.value = value
        self.color = color
    }
}

/// The renderer displayed by ``KLDimensionalBarChart``.
///
/// A mode's identity is its raw string value. KLCharts uses these values for
/// transient view identity and does not define a persistence migration policy
/// for them before version 1.0.
public enum KLDimensionalBarChartMode: String, CaseIterable, Identifiable {
    /// A grouped bar chart rendered by Swift Charts.
    case flat

    /// A rotatable projected bar chart rendered by SwiftUI Canvas.
    case dimensional

    /// The mode's raw string value, `"flat"` or `"dimensional"`.
    public var id: String { rawValue }
}

/// A grouped bar chart with interchangeable flat and dimensional renderers.
///
/// Both renderers remain mounted in one `ZStack`. The inactive renderer has
/// zero opacity and disabled hit testing, which preserves the surrounding
/// layout and its internal SwiftUI state. Switching to dimensional mode resets
/// that renderer's viewpoint. The host owns selection and passes it back
/// through ``selectedID``.
public struct KLDimensionalBarChart: View {
    /// The bars supplied to both renderers in source order.
    public let data: [KLDimensionalBarDatum]

    /// The renderer that is visible and accepts pointer or touch input.
    public let mode: KLDimensionalBarChartMode

    /// Host-localized text shown by either renderer when ``data`` is empty.
    public let emptyText: String

    /// The summary exposed by the dimensional renderer to assistive technology.
    ///
    /// For a nonempty dimensional chart, an empty value uses ``emptyText`` as
    /// the accessibility label. The dimensional empty state and all of flat
    /// mode rely on their child views' semantics and do not apply this string.
    public var accessibilityLabel: String

    /// The identity that should appear selected, or `nil` for no selection.
    ///
    /// KLCharts does not mutate this value. An unknown identifier matches no
    /// bar. Duplicate datum identifiers can make more than one bar appear
    /// selected. In dimensional mode, the matching bar scales its width,
    /// height, and depth by `1.06`. Every nonmatching bar uses `0.56` opacity.
    /// In flat mode, nonmatching bars use `0.38` opacity.
    public var selectedID: String?

    /// A change token that requests a dimensional viewpoint reset.
    ///
    /// Any value change resets yaw and pitch, even while dimensional mode is
    /// inactive. The integer's magnitude and direction have no meaning.
    public var resetToken: Int

    /// Whether dimensional mode draws labels along the series axis.
    ///
    /// This does not add a legend or change flat-mode labels.
    public var showsSeriesLabels: Bool

    /// The optional minimum horizontal width allocated to each unique group in flat mode.
    ///
    /// `nil` is passed to the layout calculation as zero. When the calculated
    /// width exceeds the available width, the flat renderer scrolls
    /// horizontally.
    public var flatMinimumGroupWidth: CGFloat?

    /// A closure that formats numeric axis labels in both renderers.
    ///
    /// The closure is stored with the view and may run repeatedly during body
    /// evaluation and Canvas drawing. Keep it inexpensive and avoid relying on
    /// a fixed call count. The default rounds to the nearest integral value,
    /// converts it to `Int`, and uses `formatted()`. Its rounded input must be
    /// representable by `Int`. NaN, positive or negative infinity, and finite
    /// values outside the `Int` range can trap at runtime. A custom formatter
    /// can define a different accepted domain, but it does not validate chart
    /// geometry.
    public var axisValueFormatter: (Double) -> String

    /// A callback invoked synchronously when a tap resolves to a datum.
    ///
    /// The closure is stored by the view. Update host-owned selection or
    /// navigation state from this callback as appropriate for the integrating
    /// app.
    public var onSelect: ((KLDimensionalBarDatum) -> Void)?

    /// A callback invoked synchronously when a tap does not resolve to a datum.
    ///
    /// The closure is stored by the view. KLCharts does not clear
    /// ``selectedID`` itself.
    public var onClearSelection: (() -> Void)?

    /// Creates a chart whose two renderers occupy one stable layout slot.
    ///
    /// - Parameters:
    ///   - data: Bars rendered by both modes. An empty array displays
    ///     `emptyText`.
    ///   - mode: The visible renderer. The other renderer remains mounted with
    ///     zero opacity and disabled hit testing.
    ///   - emptyText: Host-localized empty-state text.
    ///   - accessibilityLabel: A semantic summary for a nonempty dimensional
    ///     chart. An empty value falls back to `emptyText`. This value is not
    ///     applied to the dimensional empty state or flat mode.
    ///   - selectedID: Host-owned selected datum identity. The default is no
    ///     selection.
    ///   - resetToken: A change token for resetting the dimensional viewpoint.
    ///     The default is `0`.
    ///   - showsSeriesLabels: Whether dimensional mode draws series labels. The
    ///     default is `true`.
    ///   - flatMinimumGroupWidth: An optional minimum width per unique group in
    ///     flat mode. The default `nil` behaves as zero.
    ///   - axisValueFormatter: A stored closure used for numeric axis labels in
    ///     both renderers. It can be called repeatedly. The default rounds,
    ///     converts to `Int`, and applies integer formatting. The rounded value
    ///     must fit in `Int`. NaN, infinity, and out-of-range finite values can
    ///     trap. A custom closure can define another formatting domain.
    ///   - onSelect: A stored callback for a successful bar hit. The default is
    ///     `nil`.
    ///   - onClearSelection: A stored callback for a tap outside a bar. The
    ///     default is `nil`.
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
    ) {
        self.data = data
        self.mode = mode
        self.emptyText = emptyText
        self.accessibilityLabel = accessibilityLabel
        self.selectedID = selectedID
        self.resetToken = resetToken
        self.showsSeriesLabels = showsSeriesLabels
        self.flatMinimumGroupWidth = flatMinimumGroupWidth
        self.axisValueFormatter = axisValueFormatter
        self.onSelect = onSelect
        self.onClearSelection = onClearSelection
    }

    /// The composed chart view.
    ///
    /// The view expands to its parent's available width and height, clips
    /// overflow, cross-fades mode opacity over 0.22 seconds, and disables hit
    /// testing for the inactive renderer. The flat renderer separately applies
    /// a 0.22-second animation when its array of numeric values changes. The
    /// chart adds no explicit animation keyed to selection. Dimensional
    /// viewpoint resets use a 0.26-second snappy animation. Supply a finite
    /// height from the host layout.
    public var body: some View {
        ZStack {
            KLFlatBarChart(
                data: data,
                emptyText: emptyText,
                selectedID: selectedID,
                onSelect: onSelect,
                onClearSelection: onClearSelection,
                minimumGroupWidth: flatMinimumGroupWidth,
                axisValueFormatter: axisValueFormatter
            )
            .opacity(mode == .flat ? 1 : 0)
            .allowsHitTesting(mode == .flat)

            KLPerspectiveBarChart(
                data: data,
                emptyText: emptyText,
                accessibilityLabel: accessibilityLabel,
                selectedID: selectedID,
                isActive: mode == .dimensional,
                resetToken: resetToken,
                showsSeriesLabels: showsSeriesLabels,
                axisValueFormatter: axisValueFormatter,
                onSelect: onSelect,
                onClearSelection: onClearSelection
            )
            .opacity(mode == .dimensional ? 1 : 0)
            .allowsHitTesting(mode == .dimensional)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .clipped()
        .animation(.easeInOut(duration: 0.22), value: mode)
    }
}
