// swift-tools-version: 6.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "3D Playground",
    platforms: [
        .macOS(.v10_15)
        ],
    dependencies: [
        .package(url: "https://github.com/vapor/console-kit", from: Version(4, 15, 2)),
    ],
    targets: [
        .executableTarget(
            name: "Viewer",
            dependencies: [
                .product(name: "ConsoleKit", package: "console-kit")
            ]
        ),
    ]
)
