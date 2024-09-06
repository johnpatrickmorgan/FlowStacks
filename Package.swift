// swift-tools-version: 5.10

import PackageDescription

let package = Package(
  name: "FlowStacks",
  platforms: [
    .iOS(.v14), .watchOS(.v7), .macOS(.v11), .tvOS(.v14),
  ],
  products: [
    .library(
      name: "FlowStacks",
      targets: ["FlowStacks"]
    ),
  ],
  dependencies: [],
  targets: [
    .target(
      name: "FlowStacks",
      dependencies: []
    ),
    .testTarget(
      name: "FlowStacksTests",
      dependencies: ["FlowStacks"]
    ),
  ]
)
