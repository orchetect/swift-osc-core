// swift-tools-version: 6.0

import PackageDescription

// Note:
// - If running tests in the Xcode IDE, switch to the "IOTests" scheme if it is not already the active scheme.
// - If running tests using `xcodebuild test`, use the "IOTests" scheme.
// - If running tests using `swift test`, ensure test parallelization is disabled.

let package = Package(
    name: "IOTests",
    products: [
        // This is an empty dummy target simply to coerce Xcode to synthesize an Xcode scheme with the package name "IOTests"
        .library(name: "DummyLib", targets: ["EmptyTarget"])
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-nio", from: "2.87.0") // lowest version that supports Swift 6.0

        // Note:
        // This package requires an I/O extension package to be added as a dependency in order to build and run tests.
        // - During automated CI testing, CI adds the dependency as part of the pipeline script.
        // - During test development, you can temporarily add an I/O package here manually.
        //   For example, to use a locally cloned package:
        //     .package(path: "/Users/user/Desktop/swift-osc-io-nio")
        //   Or to use a remote package:
        //     .package(url: "https://github.com/user/swift-osc-io-nio", branch: "main")
    ],
    targets: [
        .target(
            name: "EmptyTarget"
        ),
        .testTarget(
            name: "SwiftOSCIOTests",
            dependencies: [
                .product(name: "NIOCore", package: "swift-nio")

                // Add I/O package. For example:
                //   .product(name: "SwiftOSCIO", package: "swift-core-io-nio")
            ]
        )
    ],
    swiftLanguageModes: [.v6]
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
