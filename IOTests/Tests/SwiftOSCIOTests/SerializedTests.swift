//
//  SerializedTests.swift
//  SwiftOSC Core • https://github.com/orchetect/swift-osc-core
//  © 2026 Steffan Andrews • Licensed under MIT License
//

import Testing

/// A single top-level test scope to ensure all tests within the test target run serialized (non-parallel).
///
/// That means that all I/O tests should be nested in extensions under this namespace.
///
/// > Note:
/// >
/// > The benefit of this solution means:
/// > - we don't have to rely on an Xcode TestPlan configured to disable test parallelization in the Xcode IDE
/// >   or when running `xcodebuild test`
/// > - when running `swift test` we don't require the `--no-parallel` flag
/// >
/// > The only caveat is if there is more than one test target, `swift test` will still run the test targets
/// > concurrently unless the flag is supplied. However, Xcode always runs one test target at a time.
@Suite(.serialized)
struct SerializedTests { }
