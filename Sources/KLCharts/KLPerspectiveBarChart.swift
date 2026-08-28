import SwiftUI

struct KLPerspectiveBarChart: View {
    @Environment(\.colorScheme) var colorScheme
    @GestureState var dragTranslation = CGSize.zero
    @State var settledYaw = Metrics.initialYaw
    @State var settledPitch = Metrics.initialPitch

    let data: [KLDimensionalBarDatum]
    let emptyText: String
    let accessibilityLabel: String
    let selectedID: String?
    let isActive: Bool
    let resetToken: Int
    let showsSeriesLabels: Bool
    let axisValueFormatter: (Double) -> String
    let onSelect: ((KLDimensionalBarDatum) -> Void)?
    let onClearSelection: (() -> Void)?

    var body: some View {
        Group {
            if data.isEmpty {
                KLBarChartEmptyState(text: emptyText)
            } else {
                GeometryReader { proxy in
                    ZStack {
                        Canvas { context, size in
                            drawScene(context: &context, size: size)
                        }
                        Color.clear
                            .frame(
                                width: max(proxy.size.width - 52, 1),
                                height: max(proxy.size.height - 32, 1)
                            )
                            .contentShape(Rectangle())
                            .gesture(rotationGesture)
                    }
                    .contentShape(Rectangle())
                    .simultaneousGesture(
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
                .accessibilityElement(children: .ignore)
                .accessibilityLabel(
                    Text(accessibilityLabel.isEmpty ? emptyText : accessibilityLabel)
                )
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .onChange(of: isActive) { _, active in
            guard active else { return }
            resetViewpoint()
        }
        .onChange(of: resetToken) { _, _ in
            resetViewpoint()
        }
    }

    enum Metrics {
        static let initialYaw = -18.0
        static let initialPitch = 18.0
        static let rotationSensitivity = 0.32
        static let minimumPitch = -12.0
        static let maximumPitch = 62.0
        static let horizontalInset: CGFloat = 16
        static let verticalInset: CGFloat = 12
        static let horizontalLabelReserve: CGFloat = 30
        static let verticalLabelReserve: CGFloat = 22
        static let axisLabelOffset: CGFloat = 16
        static let barWidthRatio: CGFloat = 0.58
        static let barDepthRatio: CGFloat = 0.66
        static let minimumBarHeight: CGFloat = 0.018
        static let gridDivisionCount = 4
        static let gridLineWidth: CGFloat = 0.7
        static let faceCornerRadius: CGFloat = 3
        static let selectedScale: CGFloat = 1.06
        static let unselectedOpacity = 0.56
        static let maximumVisibleGroupLabels = 7
        static let selectionHitRadius: CGFloat = 24
    }

    var yaw: Double {
        settledYaw + Double(dragTranslation.width) * Metrics.rotationSensitivity
    }

    var pitch: Double {
        min(
            max(
                settledPitch - Double(dragTranslation.height) * Metrics.rotationSensitivity,
                Metrics.minimumPitch
            ),
            Metrics.maximumPitch
        )
    }

    var rotationGesture: some Gesture {
        DragGesture(minimumDistance: 1)
            .updating($dragTranslation) { value, state, _ in
                state = value.translation
            }
            .onEnded { value in
                settledYaw += Double(value.translation.width) * Metrics.rotationSensitivity
                settledPitch = min(
                    max(
                        settledPitch
                            - Double(value.translation.height) * Metrics.rotationSensitivity,
                        Metrics.minimumPitch
                    ),
                    Metrics.maximumPitch
                )
            }
    }

    func selectedDatum(
        at location: CGPoint,
        in size: CGSize
    ) -> KLDimensionalBarDatum? {
        let projection = Projection(size: size, yaw: yaw, pitch: pitch)
        let projectedBars = bars(projection: projection)
        if let directHit = projectedBars
            .sorted(by: { $0.depth > $1.depth })
            .first(where: { bar in
                bar.faces.contains { $0.path.contains(location) }
            })
        {
            return directHit.datum
        }
        guard let nearest = projectedBars.min(by: {
            distance($0.center, location) < distance($1.center, location)
        }) else { return nil }
        guard KLDimensionalHitTesting.acceptsTap(
            distance: distance(nearest.center, location),
            hitRadius: Metrics.selectionHitRadius
        ) else { return nil }
        return nearest.datum
    }

    private func resetViewpoint() {
        withAnimation(.snappy(duration: 0.26)) {
            settledYaw = Metrics.initialYaw
            settledPitch = Metrics.initialPitch
        }
    }
}
