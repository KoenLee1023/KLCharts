import SwiftUI

extension KLPerspectiveBarChart {
    struct Point3D {
        let x: CGFloat
        let y: CGFloat
        let z: CGFloat
    }

    struct ProjectedPoint {
        let point: CGPoint
        let depth: CGFloat
    }

    struct Projection {
        let size: CGSize
        let yaw: Double
        let pitch: Double

        func project(_ point: Point3D) -> ProjectedPoint {
            let transformedPoint = transform(point)
            let bounds = transformedSceneBounds
            let availableWidth = max(
                size.width
                    - Metrics.horizontalInset * 2
                    - Metrics.horizontalLabelReserve,
                1
            )
            let availableHeight = max(
                size.height
                    - Metrics.verticalInset * 2
                    - Metrics.verticalLabelReserve,
                1
            )
            let sceneWidth = max(bounds.maxX - bounds.minX, 0.001)
            let sceneHeight = max(bounds.maxY - bounds.minY, 0.001)
            let scale = min(availableWidth / sceneWidth, availableHeight / sceneHeight)
            let fittedWidth = sceneWidth * scale
            let fittedHeight = sceneHeight * scale
            let originX = Metrics.horizontalInset
                + Metrics.horizontalLabelReserve
                + (availableWidth - fittedWidth) / 2
            let originY = Metrics.verticalInset
                + (availableHeight - fittedHeight) / 2

            return ProjectedPoint(
                point: CGPoint(
                    x: originX + (transformedPoint.x - bounds.minX) * scale,
                    y: originY + (bounds.maxY - transformedPoint.y) * scale
                ),
                depth: transformedPoint.depth
            )
        }

        private func transform(_ point: Point3D) -> (
            x: CGFloat,
            y: CGFloat,
            depth: CGFloat
        ) {
            let centeredX = point.x - 0.5
            let centeredZ = point.z - 0.5
            let yawRadians = CGFloat(yaw * .pi / 180)
            let pitchRadians = CGFloat(pitch * .pi / 180)

            let rotatedX = centeredX * cos(yawRadians)
                + centeredZ * sin(yawRadians)
            let yawDepth = -centeredX * sin(yawRadians)
                + centeredZ * cos(yawRadians)
            let rotatedY = point.y * cos(pitchRadians)
                - yawDepth * sin(pitchRadians)
            let depth = point.y * sin(pitchRadians)
                + yawDepth * cos(pitchRadians)
            return (rotatedX, rotatedY, depth)
        }

        private var transformedSceneBounds: (
            minX: CGFloat,
            maxX: CGFloat,
            minY: CGFloat,
            maxY: CGFloat
        ) {
            let corners = [
                Point3D(x: 0, y: 0, z: 0),
                Point3D(x: 1, y: 0, z: 0),
                Point3D(x: 0, y: 1, z: 0),
                Point3D(x: 1, y: 1, z: 0),
                Point3D(x: 0, y: 0, z: 1),
                Point3D(x: 1, y: 0, z: 1),
                Point3D(x: 0, y: 1, z: 1),
                Point3D(x: 1, y: 1, z: 1)
            ].map(transform)
            return (
                corners.map(\.x).min() ?? -0.5,
                corners.map(\.x).max() ?? 0.5,
                corners.map(\.y).min() ?? 0,
                corners.map(\.y).max() ?? 1
            )
        }
    }

    struct Face {
        let path: Path
        let depth: CGFloat
        let brightness: Double
    }

    struct ProjectedBar {
        let datum: KLDimensionalBarDatum
        let faces: [Face]
        let center: CGPoint
        let depth: CGFloat

        init(
            datum: KLDimensionalBarDatum,
            min: Point3D,
            max: Point3D,
            projection: Projection
        ) {
            self.datum = datum

            let worldVertices = [
                Point3D(x: min.x, y: min.y, z: min.z),
                Point3D(x: max.x, y: min.y, z: min.z),
                Point3D(x: max.x, y: max.y, z: min.z),
                Point3D(x: min.x, y: max.y, z: min.z),
                Point3D(x: min.x, y: min.y, z: max.z),
                Point3D(x: max.x, y: min.y, z: max.z),
                Point3D(x: max.x, y: max.y, z: max.z),
                Point3D(x: min.x, y: max.y, z: max.z)
            ]
            let vertices = worldVertices.map { projection.project($0) }
            let definitions: [([Int], Double)] = [
                ([0, 1, 2, 3], 0.92),
                ([4, 5, 6, 7], 0.78),
                ([0, 4, 7, 3], 0.86),
                ([1, 5, 6, 2], 0.72),
                ([3, 2, 6, 7], 1.00),
                ([0, 1, 5, 4], 0.68)
            ]
            faces = definitions.map { definition in
                let indices = definition.0
                return Face(
                    path: Self.roundedPolygonPath(
                        points: indices.map { vertices[$0].point },
                        radius: Metrics.faceCornerRadius
                    ),
                    depth: indices
                        .map { vertices[$0].depth }
                        .reduce(0, +) / CGFloat(indices.count),
                    brightness: definition.1
                )
            }

            let projectedCenter = projection.project(
                Point3D(
                    x: (min.x + max.x) / 2,
                    y: (min.y + max.y) / 2,
                    z: (min.z + max.z) / 2
                )
            )
            center = projectedCenter.point
            depth = projectedCenter.depth
        }

        private static func roundedPolygonPath(
            points: [CGPoint],
            radius: CGFloat
        ) -> Path {
            guard points.count > 2 else { return Path() }
            var starts: [CGPoint] = []
            var ends: [CGPoint] = []

            for index in points.indices {
                let previous = points[(index - 1 + points.count) % points.count]
                let current = points[index]
                let next = points[(index + 1) % points.count]
                starts.append(
                    point(from: current, toward: previous, distance: radius)
                )
                ends.append(
                    point(from: current, toward: next, distance: radius)
                )
            }

            var path = Path()
            path.move(to: ends[0])
            for index in 1..<points.count {
                path.addLine(to: starts[index])
                path.addQuadCurve(to: ends[index], control: points[index])
            }
            path.addLine(to: starts[0])
            path.addQuadCurve(to: ends[0], control: points[0])
            path.closeSubpath()
            return path
        }

        private static func point(
            from origin: CGPoint,
            toward destination: CGPoint,
            distance: CGFloat
        ) -> CGPoint {
            let dx = destination.x - origin.x
            let dy = destination.y - origin.y
            let length = max(hypot(dx, dy), 0.001)
            let constrainedDistance = min(distance, length / 3)
            return CGPoint(
                x: origin.x + dx / length * constrainedDistance,
                y: origin.y + dy / length * constrainedDistance
            )
        }
    }
}
