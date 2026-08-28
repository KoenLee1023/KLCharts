import SwiftUI

extension KLPerspectiveBarChart {
    var maximumValue: Double {
        data.map(\.value).max() ?? 1
    }

    func drawScene(context: inout GraphicsContext, size: CGSize) {
        let projection = Projection(size: size, yaw: yaw, pitch: pitch)
        drawAxes(context: &context, projection: projection)

        let projectedBars = bars(projection: projection)
            .sorted { $0.depth < $1.depth }
        for bar in projectedBars {
            let selectionOpacity = selectedID == nil || selectedID == bar.datum.id
                ? 1.0
                : Metrics.unselectedOpacity
            for face in bar.faces.sorted(by: { $0.depth < $1.depth }) {
                let bounds = face.path.boundingRect
                context.fill(
                    face.path,
                    with: .color(bar.datum.color.opacity(selectionOpacity))
                )
                context.fill(
                    face.path,
                    with: .color(.black.opacity((1 - face.brightness) * 0.34))
                )
                context.fill(
                    face.path,
                    with: .linearGradient(
                        Gradient(colors: [
                            .white.opacity(colorScheme == .dark ? 0.20 : 0.28),
                            .white.opacity(0.04),
                            .clear
                        ]),
                        startPoint: CGPoint(x: bounds.minX, y: bounds.minY),
                        endPoint: CGPoint(x: bounds.maxX, y: bounds.maxY)
                    )
                )
            }
        }
        drawLabels(context: &context, projection: projection)
    }

    func drawAxes(
        context: inout GraphicsContext,
        projection: Projection
    ) {
        let gridColor = colorScheme == .dark
            ? Color.white.opacity(0.11)
            : Color.black.opacity(0.08)
        let floorGridColor = colorScheme == .dark
            ? Color.white.opacity(0.07)
            : Color.black.opacity(0.055)

        for index in 0...Metrics.gridDivisionCount {
            let y = CGFloat(index) / CGFloat(Metrics.gridDivisionCount)
            drawLine(
                from: Point3D(x: 0, y: y, z: 0),
                to: Point3D(x: 1, y: y, z: 0),
                context: &context,
                projection: projection,
                color: gridColor
            )
        }

        let groups = orderedUnique(data.map(\.groupKey))
        for index in 0...groups.count {
            let x = CGFloat(index) / CGFloat(max(groups.count, 1))
            drawLine(
                from: Point3D(x: x, y: 0, z: 0),
                to: Point3D(x: x, y: 0, z: 1),
                context: &context,
                projection: projection,
                color: floorGridColor
            )
        }

        let series = orderedUnique(data.map(\.seriesKey))
        for index in 0...series.count {
            let z = CGFloat(index) / CGFloat(max(series.count, 1))
            drawLine(
                from: Point3D(x: 0, y: 0, z: z),
                to: Point3D(x: 1, y: 0, z: z),
                context: &context,
                projection: projection,
                color: floorGridColor
            )
        }
    }

    func drawLine(
        from start: Point3D,
        to end: Point3D,
        context: inout GraphicsContext,
        projection: Projection,
        color: Color
    ) {
        var path = Path()
        path.move(to: projection.project(start).point)
        path.addLine(to: projection.project(end).point)
        context.stroke(path, with: .color(color), lineWidth: Metrics.gridLineWidth)
    }

    func drawLabels(
        context: inout GraphicsContext,
        projection: Projection
    ) {
        let groups = orderedUnique(data.map(\.groupKey))
        let labelStride = max(
            1,
            Int(
                ceil(
                    Double(groups.count)
                        / Double(Metrics.maximumVisibleGroupLabels)
                )
            )
        )

        for (index, key) in groups.enumerated() {
            guard index.isMultiple(of: labelStride)
                || index == groups.count - 1
            else { continue }
            let x = (CGFloat(index) + 0.5) / CGFloat(groups.count)
            let point = projection.project(Point3D(x: x, y: 0, z: 1)).point
            let label = data.first { $0.groupKey == key }?.groupLabel ?? key
            context.draw(
                Text(label)
                    .font(.system(size: 8.5, weight: .medium))
                    .foregroundStyle(.secondary),
                at: CGPoint(x: point.x, y: point.y + Metrics.axisLabelOffset),
                anchor: .center
            )
        }

        if showsSeriesLabels {
            let series = orderedUnique(data.map(\.seriesKey))
            let seriesStride = max(
                1,
                Int(
                    ceil(
                        Double(series.count)
                            / Double(Metrics.maximumVisibleGroupLabels)
                    )
                )
            )
            for (index, key) in series.enumerated() {
                guard index.isMultiple(of: seriesStride)
                    || index == series.count - 1
                else { continue }
                let z = (CGFloat(index) + 0.5) / CGFloat(series.count)
                let point = projection.project(Point3D(x: 0, y: 0, z: z)).point
                let label = data.first { $0.seriesKey == key }?.seriesLabel ?? key
                context.draw(
                    Text(label)
                        .font(.system(size: 8.5, weight: .medium))
                        .foregroundStyle(.secondary),
                    at: CGPoint(
                        x: point.x - Metrics.axisLabelOffset,
                        y: point.y + Metrics.axisLabelOffset
                    ),
                    anchor: .trailing
                )
            }
        }

        for index in 0...Metrics.gridDivisionCount {
            let progress = CGFloat(index) / CGFloat(Metrics.gridDivisionCount)
            let point = projection.project(Point3D(x: 0, y: progress, z: 1)).point
            context.draw(
                Text(axisValueFormatter(maximumValue * Double(progress)))
                    .font(.system(size: 8))
                    .foregroundStyle(.secondary),
                at: CGPoint(x: point.x - 8, y: point.y),
                anchor: .trailing
            )
        }
    }

    func bars(projection: Projection) -> [ProjectedBar] {
        let groups = orderedUnique(data.map(\.groupKey))
        let series = orderedUnique(data.map(\.seriesKey))
        guard !groups.isEmpty, !series.isEmpty else { return [] }

        let groupStep = 1 / CGFloat(groups.count)
        let seriesStep = 1 / CGFloat(series.count)
        let barWidth = groupStep * Metrics.barWidthRatio
        let barDepth = seriesStep * Metrics.barDepthRatio
        let maximum = max(maximumValue, 1)

        return data.compactMap { datum in
            guard
                let groupIndex = groups.firstIndex(of: datum.groupKey),
                let seriesIndex = series.firstIndex(of: datum.seriesKey)
            else { return nil }

            let scale = selectedID == datum.id ? Metrics.selectedScale : 1
            let height = max(
                CGFloat(datum.value / maximum),
                Metrics.minimumBarHeight
            ) * scale
            let centerX = (CGFloat(groupIndex) + 0.5) * groupStep
            let centerZ = (CGFloat(seriesIndex) + 0.5) * seriesStep
            let renderedBarWidth = barWidth * scale
            let renderedBarDepth = barDepth * scale
            return ProjectedBar(
                datum: datum,
                min: Point3D(
                    x: centerX - renderedBarWidth / 2,
                    y: 0,
                    z: centerZ - renderedBarDepth / 2
                ),
                max: Point3D(
                    x: centerX + renderedBarWidth / 2,
                    y: height,
                    z: centerZ + renderedBarDepth / 2
                ),
                projection: projection
            )
        }
    }

    func distance(_ lhs: CGPoint, _ rhs: CGPoint) -> CGFloat {
        hypot(lhs.x - rhs.x, lhs.y - rhs.y)
    }

    func orderedUnique(_ values: [String]) -> [String] {
        var seen = Set<String>()
        return values.filter { seen.insert($0).inserted }
    }
}
