//
//  TestActor.swift
//  SwiftOSC Core • https://github.com/orchetect/swift-osc-core
//  © 2026 Steffan Andrews • Licensed under MIT License
//

/// A global actor to facilitate serializing tasks for unit tests that test concurrency-related
/// implementations.
@globalActor
actor TestActor {
    static let shared = TestActor()
}
