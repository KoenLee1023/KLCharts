// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "InteractionLab",
    platforms: [.macOS(.v14)],
    dependencies: [.package(path: "../..")],
    targets: [
        .executableTarget(
            name: "InteractionLab",
            dependencies: [.product(name: "KLCharts", package: "KLCharts")]
        ),
    ]
)
