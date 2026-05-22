//
//  OSCUDPServer Tests.swift
//  SwiftOSC Core • https://github.com/orchetect/swift-osc-core
//  © 2026 Steffan Andrews • Licensed under MIT License
//

import Foundation
import NIOCore
@testable import SwiftOSCIO
import Testing

extension SerializedTests {
    /// These tests provide offline self-tests to establish baseline behaviors.
    /// Online integration tests should be located in their own test suite and not located here.
    @Suite(.enabled(if: isSystemTimingStable()))
    struct OSCUDPServer_Tests {
        /// Offline test to check that an empty OSC bundle does not produce any OSC messages.
        @Test
        func offlineEmptyBundle() async throws {
            try await confirmation(expectedCount: 0) { confirmation in
                let server = OSCUDPServer()

                server.setReceiveHandler(.messages { _, _, _, _ in
                    guard !Task.isCancelled else { return }
                    confirmation()
                })

                let bundle = OSCBundle()

                // host and port here don't matter, as we're just feeding these messages into the server's internal receiver
                server.core.dispatch(packet: .bundle(bundle), remoteHost: "127.0.0.1", remotePort: 8008)

                try await Task.sleep(seconds: 1)
            }
        }

        /// Offline test to ensure rapidly received messages are received in the order they are dispatched.
        @Test(arguments: 0 ... 10)
        func offlineMessageOrdering(iteration: Int) async throws {
            _ = iteration // argument value not used, just a mechanism to repeat the test X number of times

            let server = OSCUDPServer()

            typealias MessageDetails = (message: OSCMessage, host: String, port: UInt16)
            let receiver = ItemReceiver<MessageDetails>()

            server.setReceiveHandler(.messages { message, timeTag, host, port in
                guard !Task.isCancelled else { return }
                Task { @TestActor in // must be serialized on a global actor to maintain received message ordering
                    await receiver.add((message, host: host, port: port))
                }
            })

            let msg1 = OSCMessage("/one", values: [123, "string", 500.5, 1, 2, 3, 4, "string2", true, 12345])
            let msg2 = OSCMessage("/two")
            let msg3 = OSCMessage("/three")

            // use global thread to simulate internal network thread being a dedicated thread
            DispatchQueue.global().async {
                // host and port here don't matter, as we're just feeding these messages into the server's internal receiver
                server.core.dispatch(packet: .message(msg1), remoteHost: "127.0.0.1", remotePort: 8008)
                server.core.dispatch(packet: .message(msg2), remoteHost: "192.168.0.25", remotePort: 8001)
                server.core.dispatch(packet: .message(msg3), remoteHost: "10.0.0.50", remotePort: 8080)
            }

            try await wait(require: { await receiver.items.count == 3 }, timeout: 5.0)

            let message1 = await receiver.items[0]
            #expect(message1.message == msg1)
            #expect(message1.host == "127.0.0.1")
            #expect(message1.port == 8008)

            let message2 = await receiver.items[1]
            #expect(message2.message == msg2)
            #expect(message2.host == "192.168.0.25")
            #expect(message2.port == 8001)

            let message3 = await receiver.items[2]
            #expect(message3.message == msg3)
            #expect(message3.host == "10.0.0.50")
            #expect(message3.port == 8080)
        }

        /// Offline stress-test to ensure a large volume of OSC packets are received and dispatched in order.
        @Test
        func offlineStressTest() async throws {
            let server = OSCUDPServer()

            let receiver = ItemReceiver<OSCMessage>()

            server.setReceiveHandler(.messages { message, timeTag, host, port in
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

            // use global thread to simulate internal network thread being a dedicated thread
            DispatchQueue.global().async {
                for message in sourceMessages {
                    // host and port here don't matter, as we're just feeding these messages into the server's internal receiver
                    server.core.dispatch(packet: .message(message), remoteHost: "127.0.0.1", remotePort: 8008)
                }
            }

            try await wait(require: { await receiver.items.count == 1000 }, timeout: 10.0)

            await #expect(receiver.items == sourceMessages)
        }
    }
}
