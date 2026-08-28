import KLCharts
import SwiftUI

@main
struct GeometryGalleryApp: App {
    var body: some Scene {
        WindowGroup("Geometry Gallery") {
            GeometryGalleryView()
                .frame(minWidth: 760, minHeight: 520)
        }
    }
}

private struct GeometryGalleryView: View {
    @State private var mode = KLDimensionalBarChartMode.dimensional

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Geometry Gallery").font(.largeTitle.bold())
                    Text("One model, interchangeable rendering geometry.")
                        .foregroundStyle(.secondary)
                }
                Spacer()
                Picker("Mode", selection: $mode) {
                    Text("Flat").tag(KLDimensionalBarChartMode.flat)
                    Text("Dimensional").tag(KLDimensionalBarChartMode.dimensional)
                }
                .pickerStyle(.segmented)
                .frame(width: 240)
            }

            KLDimensionalBarChart(
                data: GalleryData.values,
                mode: mode,
                emptyText: "No values",
                accessibilityLabel: "Synthetic quarterly comparison"
            )
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(.quaternary.opacity(0.35), in: RoundedRectangle(cornerRadius: 28))
        }
        .padding(32)
    }
}

@MainActor
private enum GalleryData {
    static let values: [KLDimensionalBarDatum] = [
        datum("q1-a", "Q1", "A", 42, .mint), datum("q1-b", "Q1", "B", 31, .cyan),
        datum("q2-a", "Q2", "A", 58, .mint), datum("q2-b", "Q2", "B", 47, .cyan),
        datum("q3-a", "Q3", "A", 51, .mint), datum("q3-b", "Q3", "B", 63, .cyan),
        datum("q4-a", "Q4", "A", 76, .mint), datum("q4-b", "Q4", "B", 69, .cyan),
    ]

    private static func datum(
        _ id: String,
        _ group: String,
        _ series: String,
        _ value: Double,
        _ color: Color
    ) -> KLDimensionalBarDatum {
        KLDimensionalBarDatum(
            id: id,
            groupKey: group,
            groupLabel: group,
            seriesKey: series,
            seriesLabel: "Series \(series)",
            value: value,
            color: color
        )
    }
}
