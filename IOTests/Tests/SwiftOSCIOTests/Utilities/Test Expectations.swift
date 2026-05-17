//
//  Test Expectations.swift
//  SwiftOSC Core • https://github.com/orchetect/swift-osc-core
//  © 2026 Steffan Andrews • Licensed under MIT License
//

import Foundation
import Testing

/// Test expectation that waits synchronously (non-blocking) for an expression to evaluate true,
/// failing if a timeout period is exceeded.
func wait(
    expect condition: @Sendable () async throws -> Bool,
    timeout: TimeInterval,
    pollingInterval: TimeInterval = 0.1,
    _ comment: Testing.Comment? = nil,
    sourceLocation: Testing.SourceLocation = #_sourceLocation
) async rethrows {
    let startTime = Date()

    while Date().timeIntervalSince(startTime) < timeout {
        if try await condition() { return }
        try? await Task.sleep(seconds: pollingInterval)
    }

    #expect(try await condition(), comment, sourceLocation: sourceLocation)
}

/// Test expectation that waits synchronously (non-blocking) for an expression to evaluate true,
/// throwing an error if a timeout period is exceeded.
func wait(
    require condition: @Sendable () async throws -> Bool,
    timeout: TimeInterval,
    pollingInterval: TimeInterval = 0.1,
    _ comment: Testing.Comment? = nil,
    sourceLocation: Testing.SourceLocation = #_sourceLocation
) async throws {
    let startTime = Date()

    while Date().timeIntervalSince(startTime) < timeout {
        if try await condition() { return }
        try await Task.sleep(seconds: pollingInterval)
    }

    try #require(await condition(), comment, sourceLocation: sourceLocation)
}
