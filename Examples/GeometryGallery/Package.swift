// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "GeometryGallery",
    platforms: [.macOS(.v14)],
    dependencies: [.package(path: "../..")],
    targets: [
        .executableTarget(
            name: "GeometryGallery",
            dependencies: [.product(name: "KLCharts", package: "KLCharts")]
        ),
    ]
)
