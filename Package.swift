// swift-tools-version:5.4

import PackageDescription

let package = Package(
    name: "FlowStacks",
    platforms: [
        .iOS(.v13), .watchOS(.v7), .macOS(.v11), .tvOS(.v13),
    ],
    products: [
        .library(
            name: "FlowStacks",
            targets: ["FlowStacks"]),
    ],
    dependencies: [],
    targets: [
        .target(
            name: "FlowStacks",
            dependencies: []),
        .testTarget(
            name: "FlowStacksTests",
            dependencies: ["FlowStacks"]),
    ]
)
