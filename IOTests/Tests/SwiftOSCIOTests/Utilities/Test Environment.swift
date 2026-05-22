//
//  Test Environment.swift
//  SwiftOSC Core • https://github.com/orchetect/swift-osc-core
//  © 2026 Steffan Andrews • Licensed under MIT License
//

#if canImport(Foundation)
import struct Foundation.Date
import class Foundation.Thread
import typealias Foundation.TimeInterval
#else
import struct FoundationEssentials.Date
import class FoundationEssentials.Thread
import typealias FoundationEssentials.TimeInterval
#endif

/// Use as a condition for individual tests that rely on stable/precise system timing.
func isSystemTimingStable(
    duration: TimeInterval = 0.1,
    tolerance: TimeInterval = 0.01
) -> Bool {
    let start = Date()
    Thread.sleep(forTimeInterval: duration)
    let end = Date()
    let diff = end.timeIntervalSince(start)

    let range = (duration - tolerance) ... (duration + tolerance)
    return range.contains(diff)
}
