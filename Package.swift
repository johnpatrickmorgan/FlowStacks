// swift-tools-version:5.3

import PackageDescription

let package = Package(
    name: "NStack",
    platforms: [
        .iOS(.v13), .watchOS(.v7), .macOS(.v11), .tvOS(.v13),
    ],
    products: [
        .library(
            name: "NStack",
            targets: ["NStack"]),
    ],
    dependencies: [],
    targets: [
        .target(
            name: "NStack",
            dependencies: []),
        .testTarget(
            name: "NStackTests",
            dependencies: ["NStack"]),
    ]
)
