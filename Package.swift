// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "wateco",
    platforms:[.macOS(.v11)],
    dependencies: [
        // other dependencies
        .package(url: "https://github.com/apple/swift-argument-parser.git", .upToNextMajor(from: "1.2.3")),
    ],
    targets: [
        .executableTarget(name: "wateco", dependencies: [
            // other dependencies
            .product(name: "ArgumentParser", package: "swift-argument-parser"),
        ]),
        // other targets
    ]
)
