//
//  OSCUDPSocket Lifecycle Tests.swift
//  SwiftOSC Core • https://github.com/orchetect/swift-osc-core
//  © 2026 Steffan Andrews • Licensed under MIT License
//

import Foundation
import NIOCore
@testable import SwiftOSCIO
import Testing

extension SerializedTests {
    /// These tests check lifecycle behavior to ensure init/deinit are free of deadlocks.
    @Suite(.enabled(if: isSystemTimingStable()))
    struct OSCUDPSocket_Lifecycle_Tests {
        /// In swift-osc-io-nio, recursive `.messages` bundle dispatch can make a queued
        /// delivery closure the final owner of `OSCUDPSocket.Core`. Releasing the server
        /// directly on its delivery queue deterministically reproduces that terminal
        /// lifecycle condition without relying on network traffic or scheduling timing.
        @Test(
            .bug("https://github.com/orchetect/swift-osc-io-nio/pull/6"),
            arguments: [true, false]
        )
        func deinit_WhenReleasedOnDeliveryQueue_DoesNotDeadlock(isShouldStart: Bool) async throws {
            let queue = DispatchQueue(
                label: "com.orchetect.SwiftOSC.Tests.OSCUDPSocket.delivery.\(UUID().uuidString)"
            )

            try await withCheckedThrowingContinuation { continuation in
                queue.async {
                    do {
                        try createAndReleaseSocket(on: queue, isShouldStart: isShouldStart)
                        continuation.resume()
                    } catch {
                        continuation.resume(throwing: error)
                    }
                }
            }
        }

        // MARK: - Helpers

        private func createAndReleaseSocket(on queue: DispatchQueue, isShouldStart: Bool) throws {
            let socket = OSCUDPSocket(
                localPort: nil,
                remoteHost: "localhost",
                remotePort: nil,
                interface: nil,
                isIPv4BroadcastEnabled: false,
                isIPv6Enabled: false,
                queue: queue,
                receiveHandler: .messages { message, timeTag, host, port in
                    // empty
                }
            )

            if isShouldStart {
                try socket.start()
                try socket.send(.message("/test", values: []))
            }

            withExtendedLifetime(socket) { }
        }
    }
}
