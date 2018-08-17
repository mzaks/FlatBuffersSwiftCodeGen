// swift-tools-version:4.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "FlatBuffersSwiftCodeGen",
    dependencies: [
    ],
    targets: [
        .target(
            name: "FlatBuffersSwiftCodeGenCore",
            dependencies: []),
        .target(
            name: "FlatBuffersSwiftCodeGen",
            dependencies: ["FlatBuffersSwiftCodeGenCore"]),
        .testTarget(
            name: "FlatBuffersSwiftCodeGenTests",
            dependencies: ["FlatBuffersSwiftCodeGenCore"]
        )
    ]
)
