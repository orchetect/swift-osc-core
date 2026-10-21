//
//  OSCTCPClient Lifecycle Tests.swift
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
    struct OSCTCPClient_Lifecycle_Tests {
        /// In swift-osc-io-nio, recursive `.messages` bundle dispatch can make a queued
        /// delivery closure the final owner of `OSCTCPClient.Core`. Releasing the server
        /// directly on its delivery queue deterministically reproduces that terminal
        /// lifecycle condition without relying on network traffic or scheduling timing.
        @Test(
            .bug("https://github.com/orchetect/swift-osc-io-nio/pull/6"),
            arguments: [true, false]
        )
        func deinit_WhenReleasedOnDeliveryQueue_DoesNotDeadlock(isShouldConnect: Bool) async throws {
            let queue = DispatchQueue(
                label: "com.orchetect.SwiftOSC.Tests.OSCTCPClient.delivery.\(UUID().uuidString)"
            )

            try await withCheckedThrowingContinuation { continuation in
                queue.async {
                    do {
                        try createAndReleaseClient(on: queue, isShouldConnect: isShouldConnect)
                        continuation.resume()
                    } catch {
                        continuation.resume(throwing: error)
                    }
                }
            }
        }

        // MARK: - Helpers

        private func createAndReleaseClient(on queue: DispatchQueue, isShouldConnect: Bool) throws {
            // a TCP server is needed in order to test a TCP client
            let server = OSCTCPServer(port: nil, isIPv6Enabled: false)
            try server.start()

            let client = OSCTCPClient(
                remoteHost: "localhost",
                remotePort: server.localPort,
                interface: nil,
                isIPv6Enabled: false,
                framingMode: .osc1_1,
                queue: queue,
                receiveHandler: .messages { message, timeTag, host, port in
                    // empty
                }
            )

            if isShouldConnect {
                try client.connect(timeout: 5.0)
                try client.send(.message("/test", values: []))
            }

            withExtendedLifetime(server) { }
            withExtendedLifetime(client) { }
        }
    }
}
