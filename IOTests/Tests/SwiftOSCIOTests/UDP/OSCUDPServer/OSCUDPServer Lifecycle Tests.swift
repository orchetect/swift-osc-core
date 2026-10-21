//
//  OSCUDPServer Lifecycle Tests.swift
//  SwiftOSC Core • https://github.com/orchetect/swift-osc-core
//  © 2026 Steffan Andrews • Licensed under MIT License
//

import Foundation
import NIOCore
@testable import SwiftOSCIO
import Testing

extension SerializedTests {
    /// These tests check lifecycle behavior.
    @Suite(.enabled(if: isSystemTimingStable()))
    struct OSCUDPServer_Lifecycle_Tests {
        /// In swift-osc-io-nio, recursive `.messages` bundle dispatch can make a queued
        /// delivery closure the final owner of `OSCUDPServer.Core`. Releasing the server
        /// directly on its delivery queue deterministically reproduces that terminal
        /// lifecycle condition without relying on network traffic or scheduling timing.
        @Test(.bug("https://github.com/orchetect/swift-osc-io-nio/pull/6"))
        func deinit_WhenReleasedOnDeliveryQueue_DoesNotDeadlock() async {
            let queue = DispatchQueue(
                label: "com.orchetect.SwiftOSC.Tests.OSCUDPServer.delivery"
            )

            await withCheckedContinuation { continuation in
                queue.async {
                    createAndReleaseServer(on: queue)
                    continuation.resume()
                }
            }
        }

        // MARK: - Helpers

        private func createAndReleaseServer(on queue: DispatchQueue) {
            let server = OSCUDPServer(
                port: nil,
                interface: nil,
                isPortReuseEnabled: false,
                isIPv6Enabled: false,
                queue: queue,
                receiveHandler: .messages { message, timeTag, host, port in
                    // empty
                }
            )

            withExtendedLifetime(server) { }
        }
    }
}
