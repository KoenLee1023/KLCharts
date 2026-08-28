import Charts
import SwiftUI

struct KLFlatBarChart: View {
    let data: [KLDimensionalBarDatum]
    let emptyText: String
    let selectedID: String?
    let onSelect: ((KLDimensionalBarDatum) -> Void)?
    let onClearSelection: (() -> Void)?
    let minimumGroupWidth: CGFloat?
    let axisValueFormatter: (Double) -> String

    var body: some View {
        Group {
            if data.isEmpty {
                KLBarChartEmptyState(text: emptyText)
            } else {
                GeometryReader { proxy in
                    let chartWidth = KLFlatBarChartLayout.chartWidth(
                        availableWidth: proxy.size.width,
                        groupCount: orderedUnique(data.map(\.groupKey)).count,
                        minimumGroupWidth: minimumGroupWidth ?? 0
                    )
                    ScrollView(.horizontal, showsIndicators: false) {
                        chartContent
                            .frame(width: chartWidth, height: proxy.size.height)
                    }
                    .scrollDisabled(chartWidth <= proxy.size.width)
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private enum Metrics {
        static let unselectedOpacity = 0.38
    }

    private var chartContent: some View {
        Chart(data) { datum in
            BarMark(
                x: .value("Group", datum.groupLabel),
                y: .value("Value", datum.value)
            )
            .position(by: .value("Series", datum.seriesLabel))
            .foregroundStyle(datum.color.gradient)
            .opacity(
                selectedID == nil || selectedID == datum.id
                    ? 1
                    : Metrics.unselectedOpacity
            )
            .cornerRadius(5)
        }
        .chartLegend(.hidden)
        .chartXAxis {
            AxisMarks { value in
                AxisValueLabel {
                    if let label = value.as(String.self) {
                        Text(label)
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                    }
                }
            }
        }
        .chartYAxis {
            AxisMarks(position: .leading) { value in
                AxisGridLine()
                    .foregroundStyle(Color.secondary.opacity(0.12))
                AxisValueLabel {
                    if let amount = value.as(Double.self) {
                        Text(axisValueFormatter(amount))
                            .font(.caption2)
                    }
                }
            }
        }
        .animation(.easeInOut(duration: 0.22), value: data.map(\.value))
        .chartOverlay { _ in
            GeometryReader { proxy in
                Color.clear
                    .contentShape(Rectangle())
                    .gesture(
                        SpatialTapGesture().onEnded { event in
                            guard let datum = selectedDatum(
                                at: event.location,
                                in: proxy.size
                            ) else {
                                onClearSelection?()
                                return
                            }
                            onSelect?(datum)
                        }
                    )
            }
        }
        .padding(.top, 6)
    }

    private func selectedDatum(
        at location: CGPoint,
        in size: CGSize
    ) -> KLDimensionalBarDatum? {
        guard !data.isEmpty, size.width > 0 else { return nil }
        let groups = orderedUnique(data.map(\.groupKey))
        guard !groups.isEmpty else { return nil }
        let progress = min(max(location.x / size.width, 0), 0.999)
        let scaledPosition = progress * CGFloat(groups.count)
        let groupIndex = min(Int(scaledPosition), groups.count - 1)
        let groupData = data.filter { $0.groupKey == groups[groupIndex] }
        let series = orderedUnique(groupData.map(\.seriesKey))
        guard !series.isEmpty else { return nil }
        let withinGroup = scaledPosition - CGFloat(groupIndex)
        let seriesIndex = min(
            Int(withinGroup * CGFloat(series.count)),
            series.count - 1
        )
        guard let datum = groupData.first(where: {
            $0.seriesKey == series[seriesIndex]
        }) else { return nil }
        let maximum = max(data.map(\.value).max() ?? 1, 1)
        let plotBottom = max(size.height - 24, 1)
        let plotTop: CGFloat = 8
        let plotHeight = max(plotBottom - plotTop, 1)
        let barTop = plotBottom
            - plotHeight * CGFloat(max(datum.value, 0) / maximum)
        guard location.y >= barTop - 8, location.y <= plotBottom + 6 else {
            return nil
        }
        return datum
    }

    private func orderedUnique(_ values: [String]) -> [String] {
        var seen = Set<String>()
        return values.filter { seen.insert($0).inserted }
    }
}

/// Pure layout calculations used by KLCharts' flat renderer.
public enum KLFlatBarChartLayout {
    /// Calculates the flat chart canvas width.
    ///
    /// The implementation evaluates
    /// `max(availableWidth, CGFloat(max(groupCount, 1)) * minimumGroupWidth)`.
    /// A `groupCount` of zero or less is therefore treated as one. Zero and
    /// negative minimum widths are not rejected. Positive and negative
    /// infinity and NaN are also passed directly through Swift's `CGFloat`
    /// multiplication and `max` comparison. A NaN `availableWidth` produces
    /// NaN. With a finite `availableWidth`, a NaN `minimumGroupWidth` produces
    /// that available width because Swift's `max(finite, NaN)` returns its
    /// first argument. Positive infinity in either width produces positive
    /// infinity unless `availableWidth` is NaN. Negative infinite minimum
    /// width leaves a finite available width unchanged.
    ///
    /// - Parameters:
    ///   - availableWidth: The width offered by the host layout. It is not
    ///     clamped or checked for finiteness.
    ///   - groupCount: The number of unique groups. Values below one are
    ///     replaced with one for this calculation.
    ///   - minimumGroupWidth: The requested width per effective group. It is
    ///     not clamped or checked for finiteness.
    /// - Returns: The greater of `availableWidth` and the effective group count
    ///   multiplied by `minimumGroupWidth`, with the nonfinite behavior
    ///   described above.
    public static func chartWidth(
        availableWidth: CGFloat,
        groupCount: Int,
        minimumGroupWidth: CGFloat
    ) -> CGFloat {
        max(availableWidth, CGFloat(max(groupCount, 1)) * minimumGroupWidth)
    }
}

struct KLBarChartEmptyState: View {
    let text: String

    var body: some View {
        VStack(spacing: 9) {
            Image(systemName: "chart.bar.xaxis")
                .font(.title2)
            Text(text)
                .font(.subheadline)
        }
        .foregroundStyle(.secondary)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
