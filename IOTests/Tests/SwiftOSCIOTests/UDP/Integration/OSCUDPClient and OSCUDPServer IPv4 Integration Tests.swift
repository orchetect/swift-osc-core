//
//  OSCUDPClient and OSCUDPServer IPv4 Integration Tests.swift
//  SwiftOSC Core • https://github.com/orchetect/swift-osc-core
//  © 2026 Steffan Andrews • Licensed under MIT License
//

import Foundation
import NIOCore
@testable import SwiftOSCIO
import Testing

extension SerializedTests {
    /// Tests focusing on individual behaviors are generally tested exclusively using the known IPv4 local
    /// loopback address (127.0.0.1).
    ///
    /// Individual tests involving host resolution of "localhost" or IPv6 compatibility using "::1" are
    /// separate discrete tests meant to test only novel differences in behavior between
    /// using a _hostname vs. IP address_ or between _IPv4 vs. IPv6_ and need not overlap with the
    /// baseline IPv4 behavior tests, which would be largely redundant in re-proving the same functionality.
    @Suite(.enabled(if: isSystemTimingStable()))
    struct OSCUDPClient_and_OSCUDPServer_IPv4_Integration_Tests {
        /// Online stress-test (IPv4) to ensure a large volume of OSC packets are received and dispatched in order.
        @Test
        func onlineStressTest() async throws {
            let isFlakey = !isSystemTimingStable()

            let server = OSCUDPServer(port: nil, interface: "0.0.0.0", queue: nil, receiveHandler: nil)
            try await Task.sleep(seconds: isFlakey ? 5.0 : 0.1)

            // sanity check - IPv6 should be disabled by default, as per the OSCUDPServerProtocol spec.
            #expect(!server.isIPv6Enabled)

            try server.start()
            try await Task.sleep(seconds: isFlakey ? 5.0 : 0.5)

            let port = server.localPort
            print("Using server listen port \(port)")

            let receiver = ItemReceiver<OSCMessage>()

            server.setReceiveHandler(.messages(timeTagMode: .ignore) { message, timeTag, host, port in
                guard !Task.isCancelled else { return }
                Task { @TestActor in // must be serialized on a global actor to maintain received message ordering
                    await receiver.add(message)
                }
            })

            var possibleValuePacks: [OSCValues] {
                [
                    [],
                    [UUID().uuidString],
                    [Int.random(in: 10000 ... 10_000_000)],
                    [Int.random(in: 10000 ... 10_000_000), UUID().uuidString, 456.78, true]
                ]
            }

            let sourceMessages: [OSCMessage] = Array(1 ... 1000).map { value in
                OSCMessage("/some/address/\(UUID().uuidString)", values: possibleValuePacks.randomElement()!)
            }

            let client = OSCUDPClient()
            try await Task.sleep(seconds: isFlakey ? 5.0 : 0.1)

            // sanity check - IPv6 should be disabled by default, as per the OSCUDPClientProtocol spec.
            #expect(!client.isIPv6Enabled)

            // use global thread to simulate internal network thread being a dedicated thread
            let srcLocSendToServer: SourceLocation = #_sourceLocation
            DispatchQueue.global().async {
                for message in sourceMessages {
                    do { try client.send(message, to: "127.0.0.1", port: port) }
                    catch { Issue.record(error, sourceLocation: srcLocSendToServer) }
                    
                    // randomly ask the client to send a message to a different (non-existent) host to ensure
                    // it is able to resume sending gracefully without permanently dropping the socket
                    if Int.random(in: 0 ... 20) == 10 {
                        // ignore errors here
                        try? client.send(message, to: "\(UUID().uuidString)", port: UInt16.random(in: 60_000 ... 61_000))
                    }
                }
            }

            await wait(expect: { await receiver.items.count == 1000 }, timeout: isFlakey ? 30.0 : 20.0)
            try await #require(receiver.items.count == 1000)

            await #expect(receiver.items == sourceMessages)
        }
    }
}
