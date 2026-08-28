// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "KLCharts",
    platforms: [.iOS(.v17), .macOS(.v14)],
    products: [.library(name: "KLCharts", targets: ["KLCharts"])],
    dependencies: [
        .package(
            url: "https://github.com/swiftlang/swift-docc-plugin",
            from: "1.4.0"
        ),
    ],
    targets: [
        .target(name: "KLCharts"),
        .testTarget(name: "KLChartsTests", dependencies: ["KLCharts"]),
    ]
)
