// swift-tools-version:4.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "FlatBuffersSwiftCodeGen",
    dependencies: [
        .package(url: "https://github.com/apple/swift-package-manager.git", from: "0.1.0")
    ],
    targets: [
        .target(
            name: "FlatBuffersSwiftCodeGenCore",
            dependencies: []),
        .target(
            name: "FlatBuffersSwiftCodeGen",
            dependencies: ["FlatBuffersSwiftCodeGenCore", "Utility"]),
        .testTarget(
            name: "FlatBuffersSwiftCodeGenTests",
            dependencies: ["FlatBuffersSwiftCodeGenCore"]
        )
    ]
)
