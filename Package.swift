// swift-tools-version: 6.0

import Foundation
import PackageDescription

let package = Package(
    name: "swift-osc-core",
    platforms: [.macOS(.v10_15), .iOS(.v13), .tvOS(.v13), .watchOS(.v6)],
    products: [
        .library(name: "SwiftOSCCore", targets: ["SwiftOSCCore"]),
        .library(name: "SwiftOSCIOCore", targets: ["SwiftOSCIOInternals"]),
        .library(name: "SwiftOSCIOInternals", targets: ["SwiftOSCIOInternals"])
    ],
    dependencies: [
        .package(url: "https://github.com/orchetect/swift-ascii", from: "1.3.1"),
        .package(url: "https://github.com/orchetect/swift-data-parsing", from: "0.1.2"),
        .package(url: "https://github.com/apple/swift-numerics", from: "1.1.1")
    ],
    targets: [
        .target(
            name: "SwiftOSCCore",
            dependencies: [
                .product(name: "SwiftASCII", package: "swift-ascii"),
                .product(name: "SwiftDataParsing", package: "swift-data-parsing")
            ],
            swiftSettings: [.define("DEBUG", .when(configuration: .debug))]
        ),
        .target(
            name: "SwiftOSCIOCore",
            dependencies: [
                "SwiftOSCCore",
                .product(name: "SwiftDataParsing", package: "swift-data-parsing")
            ]
        ),
        .target(
            name: "SwiftOSCIOInternals",
            dependencies: [
                "SwiftOSCCore",
                "SwiftOSCIOCore",
                .product(name: "SwiftDataParsing", package: "swift-data-parsing")
            ]
        ),
        .testTarget(
            name: "SwiftOSCCoreTests",
            dependencies: [
                "SwiftOSCCore",
                .product(name: "Numerics", package: "swift-numerics")
            ]
        ),
        .testTarget(
            name: "SwiftOSCIOCoreTests",
            dependencies: [
                "SwiftOSCIOCore",
                .product(name: "Numerics", package: "swift-numerics")
            ]
        ),
        .testTarget(
            name: "SwiftOSCIOInternalsTests",
            dependencies: [
                "SwiftOSCIOInternals",
                .product(name: "Numerics", package: "swift-numerics")
            ]
        )
    ]
)

// MARK: - Utilities

func hasEnvironmentVariable(_ name: String) -> Bool {
    ProcessInfo.processInfo.environment[name] != nil
}

// MARK: - CI Pipeline

if hasEnvironmentVariable("GITHUB_ACTIONS") {
    for target in package.targets.filter(\.isTest) {
        if target.swiftSettings == nil { target.swiftSettings = [] }
        target.swiftSettings? += [.define("GITHUB_ACTIONS", .when(configuration: .debug))]
    }
}
