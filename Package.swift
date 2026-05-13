// swift-tools-version: 6.0

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

// MARK: - Environment

#if canImport(Foundation) || canImport(CoreFoundation)
    #if canImport(Foundation)
        import class Foundation.ProcessInfo

        func getEnvironmentVar(_ name: String) -> String? {
            ProcessInfo.processInfo.environment[name]
        }

    #elseif canImport(CoreFoundation)
        import CoreFoundation

        func getEnvironmentVar(_ name: String) -> String? {
            guard let rawValue = getenv(name) else { return nil }
            return String(utf8String: rawValue)
        }
    #endif

    func isEnvironmentVarTrue(_ name: String) -> Bool {
        guard let value = getEnvironmentVar(name)?
            .trimmingCharacters(in: .whitespacesAndNewlines)
        else { return false }
        return ["true", "yes", "1"].contains(value.lowercased())
    }

    // MARK: - CI Pipeline

    if isEnvironmentVarTrue("GITHUB_ACTIONS") {
        for target in package.targets.filter(\.isTest) {
            if target.swiftSettings == nil { target.swiftSettings = [] }
            target.swiftSettings? += [.define("GITHUB_ACTIONS", .when(configuration: .debug))]
        }
    }
#endif
