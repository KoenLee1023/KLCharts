import KLCharts
import SwiftUI

@main
struct InteractionLabApp: App {
    var body: some Scene {
        WindowGroup("Interaction Lab") {
            InteractionLabView()
                .frame(minWidth: 760, minHeight: 520)
        }
    }
}

private struct InteractionLabView: View {
    @State private var selectedID: String?
    @State private var resetToken = 0

    var body: some View {
        VStack(alignment: .leading, spacing: 18) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Interaction Lab").font(.largeTitle.bold())
                    Text(selectedID.map { "Selected · \($0)" } ?? "Tap a bar to inspect selection")
                        .foregroundStyle(.secondary)
                }
                Spacer()
                Button("Reset viewpoint") { resetToken += 1 }
            }

            KLDimensionalBarChart(
                data: LabData.values,
                mode: .dimensional,
                emptyText: "No samples",
                accessibilityLabel: "Interactive synthetic samples",
                selectedID: selectedID,
                resetToken: resetToken,
                onSelect: { selectedID = $0.id },
                onClearSelection: { selectedID = nil }
            )
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 28))
        }
        .padding(32)
    }
}

@MainActor
private enum LabData {
    static let values: [KLDimensionalBarDatum] = (0..<5).flatMap { group in
        (0..<3).map { series in
            KLDimensionalBarDatum(
                id: "g\(group)-s\(series)",
                groupKey: "g\(group)",
                groupLabel: "Group \(group + 1)",
                seriesKey: "s\(series)",
                seriesLabel: "Layer \(series + 1)",
                value: Double((group + 2) * (series + 3)),
                color: [.teal, .indigo, .orange][series]
            )
        }
    }
}
