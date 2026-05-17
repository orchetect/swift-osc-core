//
//  OSCTCPClient and OSCTCPServer Tests.swift
//  SwiftOSC Core • https://github.com/orchetect/swift-osc-core
//  © 2026 Steffan Andrews • Licensed under MIT License
//

import Foundation
@testable import SwiftOSCIO
import Testing

@Suite(.enabled(if: isSystemTimingStable()), .serialized)
struct OSCTCPClient_and_OSCTCPServer_Tests {
    /// Ensure rapidly received messages are dispatched in the order they are received.
    @Test(arguments: 0 ... 10)
    func messageOrdering(iteration: Int) async throws {
        _ = iteration // argument value not used, just a mechanism to repeat the test X number of times

        // we aren't starting the server, so passing port 0 or nil has no meaningful effect
        let server = OSCTCPServer(port: nil)

        final actor Receiver {
            var messages: [(message: OSCMessage, host: String, port: UInt16)] = []
            func received(_ message: OSCMessage, host: String, port: UInt16) {
                messages.append((message, host, port))
            }
        }

        let receiver = Receiver()

        server.setReceiveHandler(.messages(timeTagMode: .ignore) { message, timeTag, host, port in
            guard !Task.isCancelled else { return }
            Task {
                await receiver.received(message, host: host, port: port)
            }
        })

        let msg1 = OSCMessage("/one", values: [123, "string", 500.5, 1, 2, 3, 4, "string2", true, 12345])
        let msg2 = OSCMessage("/two")
        let msg3 = OSCMessage("/three")

        // use global thread to simulate internal network thread being a dedicated thread
        DispatchQueue.global().async {
            server.core.dispatch(packet: .message(msg1), remoteHost: "127.0.0.1", remotePort: 8000)
            server.core.dispatch(packet: .message(msg2), remoteHost: "192.168.0.25", remotePort: 8001)
            server.core.dispatch(packet: .message(msg3), remoteHost: "10.0.0.50", remotePort: 8080)
        }

        try await wait(require: { await receiver.messages.count == 3 }, timeout: 10.0)

        let message1 = await receiver.messages[0]
        #expect(message1.message == msg1)
        #expect(message1.host == "127.0.0.1")
        #expect(message1.port == 8000)

        let message2 = await receiver.messages[1]
        #expect(message2.message == msg2)
        #expect(message2.host == "192.168.0.25")
        #expect(message2.port == 8001)

        let message3 = await receiver.messages[2]
        #expect(message3.message == msg3)
        #expect(message3.host == "10.0.0.50")
        #expect(message3.port == 8080)
    }

    /// Offline stress-test to ensure a large volume of OSC packets are received and dispatched in order.
    @Test
    func stressTestOffline() async throws {
        // we aren't starting the server, so passing port 0 or nil has no meaningful effect
        let server = OSCTCPServer(port: nil)

        final actor Receiver {
            var messages: [OSCMessage] = []
            func received(_ message: OSCMessage) {
                messages.append(message)
            }
        }

        let receiver = Receiver()

        server.setReceiveHandler(.messages(timeTagMode: .ignore) { message, timeTag, host, port in
            guard !Task.isCancelled else { return }
            Task {
                await receiver.received(message)
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
                server.core.dispatch(packet: .message(message), remoteHost: "127.0.0.1", remotePort: 8000)
            }
        }

        try await wait(require: { await receiver.messages.count == 1000 }, timeout: 20.0)

        await #expect(receiver.messages == sourceMessages)
    }

    // This test is especially flakey on GitHub Actions runners, so we'll only run it in a local context.
    #if !GITHUB_ACTIONS
    /// Online stress-test to ensure a large volume of OSC packets are received and dispatched in order.
    /// - This test is repeated for each TCP framing mode.
    /// - This also tests that when passing local port 0 to server's init, after calling `start()` the `localPort`
    ///   property is then populated with the system-assigned port.
    @Test(.serialized, arguments: OSCTCPFramingMode.allCases)
    func stressTestOnline(framingMode: OSCTCPFramingMode) async throws {
        let isStable = isSystemTimingStable()

        // setup server

        // binding to port 0 or nil will cause the system to assign a random available port
        let server = OSCTCPServer(port: nil, framingMode: framingMode)
        try await Task.sleep(seconds: isStable ? 0.1 : 5.0)

        try server.start()
        try await Task.sleep(seconds: isStable ? 0.5 : 5.0)

        // cleanup when test case exists so no open sockets hang or interfere with other test cases
        defer { server.stop() }

        print("Using server listen port \(server.localPort)")

        // setup client
        // (must be done after calling start on server so we have a non-zero local server port to use)

        let client = OSCTCPClient(remoteHost: "127.0.0.1", remotePort: server.localPort, framingMode: framingMode)
        try await Task.sleep(seconds: isStable ? 0.1 : 5.0)

        try client.connect()
        try await Task.sleep(seconds: isStable ? 0.5 : 5.0)

        #expect(server.clients.count == 1)

        // prep test types and variables

        final actor Receiver {
            var messages: [OSCMessage] = []
            func received(_ message: OSCMessage) {
                messages.append(message)
            }
        }

        var possibleValuePacks: [OSCValues] {
            [
                [],
                [UUID().uuidString],
                [Int.random(in: 10000 ... 10_000_000)],
                [Int.random(in: 10000 ... 10_000_000), UUID().uuidString, 456.78, true]
            ]
        }

        let expectedMsgCount = 1000
        let sourceMessages: [OSCMessage] = Array(1 ... expectedMsgCount).map { value in
            OSCMessage("/some/address/\(UUID().uuidString)", values: possibleValuePacks.randomElement()!)
        }

        // Cycle 1: test client -> server

        let serverReceiver = Receiver()

        server.setReceiveHandler(.messages(timeTagMode: .ignore) { message, timeTag, host, port in
            guard !Task.isCancelled else { return }
            Task {
                await serverReceiver.received(message)
            }
        })

        // use global thread to simulate internal network thread being a dedicated thread
        let srcLocSendToServer: SourceLocation = #_sourceLocation
        DispatchQueue.global().async {
            for message in sourceMessages {
                do { try client.send(message) }
                catch { Issue.record(error, sourceLocation: srcLocSendToServer) }
            }
        }

        await wait(expect: { await serverReceiver.messages.count == expectedMsgCount }, timeout: isStable ? 5.0 : 20.0)
        try await #require(serverReceiver.messages.count == expectedMsgCount)

        await #expect(serverReceiver.messages == sourceMessages)

        // Cycle 2: test server -> client

        let clientReceiver = Receiver()

        client.setReceiveHandler(.messages(timeTagMode: .ignore) { message, timeTag, host, port in
            guard !Task.isCancelled else { return }
            Task {
                await clientReceiver.received(message)
            }
        })

        // use global thread to simulate internal network thread being a dedicated thread
        let srcLocSendToClient: SourceLocation = #_sourceLocation
        DispatchQueue.global().async {
            for message in sourceMessages {
                server.send(message) { clientID, error in
                    Issue.record(error, sourceLocation: srcLocSendToClient)
                }
            }
        }

        await wait(expect: { await clientReceiver.messages.count == expectedMsgCount }, timeout: isStable ? 10.0 : 20.0)
        try await #require(clientReceiver.messages.count == expectedMsgCount)

        await #expect(clientReceiver.messages == sourceMessages)

        // double-check Cycle 1 results have not changed
        await #expect(serverReceiver.messages.count == expectedMsgCount) // should not have changed
    }
    #endif

    /// Check that connections are added when an incoming connection is made,
    /// and check that connections are removed when a connection is closed remotely.
    @Test
    func clientConnectDisconnect() async throws {
        let isStable = isSystemTimingStable()

        // setup server

        // binding to port 0 or nil will cause the system to assign a random available port
        let server = OSCTCPServer(port: nil, framingMode: .osc1_1)
        try await Task.sleep(seconds: isStable ? 0.1 : 5.0)

        try server.start()
        try await Task.sleep(seconds: isStable ? 0.5 : 5.0)

        // cleanup when test case exists so no open sockets hang or interfere with other test cases
        defer { server.stop() }

        print("Using server listen port \(server.localPort)")

        // setup client 1
        // (must be done after calling start on server so we have a non-zero local server port to use)

        let client1 = OSCTCPClient(remoteHost: "127.0.0.1", remotePort: server.localPort, framingMode: .osc1_1)
        try await Task.sleep(seconds: isStable ? 0.1 : 5.0)

        try client1.connect()
        try await Task.sleep(seconds: isStable ? 0.5 : 5.0)

        #expect(server.clients.count == 1)

        // setup client 2
        // (must be done after calling start on server so we have a non-zero local server port to use)

        let client2 = OSCTCPClient(remoteHost: "127.0.0.1", remotePort: server.localPort, framingMode: .osc1_1)
        try await Task.sleep(seconds: isStable ? 0.1 : 5.0)

        try client2.connect()
        try await Task.sleep(seconds: isStable ? 0.5 : 5.0)

        #expect(server.clients.count == 2)

        // disconnect client 1

        client1.close()
        try await Task.sleep(seconds: isStable ? 1.0 : 5.0)

        #expect(server.clients.count == 1)

        // disconnect client 2

        client2.close()
        try await Task.sleep(seconds: isStable ? 1.0 : 5.0)

        #expect(server.clients.isEmpty)
    }

    /// Tests starting TCP server, then stopping it, then restarting it again.
    @Test
    func startStopTCPServer() async throws {
        let isStable = isSystemTimingStable()

        // binding to port 0 or nil will cause the system to assign a random available port
        let server = OSCTCPServer(port: nil, framingMode: .osc1_1)
        try await Task.sleep(seconds: isStable ? 0.1 : 5.0)

        try server.start()
        try await Task.sleep(seconds: isStable ? 0.5 : 5.0)

        server.stop()
        try await Task.sleep(seconds: isStable ? 0.5 : 5.0)

        try server.start()
        try await Task.sleep(seconds: isStable ? 0.5 : 5.0)

        // cleanup when test case exists so no open sockets hang or interfere with other test cases
        defer { server.stop() }

        print("Using server listen port \(server.localPort)")

        // setup client 1
        // (must be done after calling start on server so we have a non-zero local server port to use)

        let client1 = OSCTCPClient(remoteHost: "127.0.0.1", remotePort: server.localPort, framingMode: .osc1_1)
        try await Task.sleep(seconds: isStable ? 0.1 : 5.0)

        try client1.connect()
        try await Task.sleep(seconds: isStable ? 0.5 : 5.0)

        #expect(server.clients.count == 1)
    }

    /// Tests multiple connected clients.
    @Test
    func multipleClientTestOnline() async throws {
        let isStable = isSystemTimingStable()
        let framingMode: OSCTCPFramingMode = .osc1_1

        // setup server

        // binding to port 0 or nil will cause the system to assign a random available port
        let server = OSCTCPServer(port: nil, framingMode: framingMode)
        try await Task.sleep(seconds: isStable ? 0.1 : 5.0)

        try server.start()
        try await Task.sleep(seconds: isStable ? 0.5 : 5.0)

        print("Using server listen port \(server.localPort)")

        // setup clients
        // (must be done after calling start on server so we have a non-zero local server port to use)

        // client 1

        let client1 = OSCTCPClient(remoteHost: "127.0.0.1", remotePort: server.localPort, framingMode: framingMode)
        try await Task.sleep(seconds: isStable ? 0.1 : 5.0)

        try client1.connect()
        try await Task.sleep(seconds: isStable ? 0.5 : 5.0)

        #expect(server.clients.count == 1)
        let client1ID = try #require(server.clients.first?.key)

        // client 2

        let client2 = OSCTCPClient(remoteHost: "127.0.0.1", remotePort: server.localPort, framingMode: framingMode)
        try await Task.sleep(seconds: isStable ? 0.1 : 5.0)

        try client2.connect()
        try await Task.sleep(seconds: isStable ? 0.5 : 5.0)

        #expect(server.clients.count == 2)
        let client2ID = try #require(server.clients.filter { $0.key != client1ID }.first?.key)

        // set up receivers

        final actor Receiver {
            var messages: [OSCMessage] = []
            func received(_ message: OSCMessage) {
                messages.append(message)
            }

            func reset() {
                messages.removeAll()
            }
        }

        let serverReceiver = Receiver()

        server.setReceiveHandler(.messages(timeTagMode: .ignore) { message, timeTag, host, port in
            guard !Task.isCancelled else { return }
            Task {
                await serverReceiver.received(message)
            }
        })

        let client1Receiver = Receiver()

        client1.setReceiveHandler(.messages(timeTagMode: .ignore) { message, timeTag, host, port in
            guard !Task.isCancelled else { return }
            Task {
                await client1Receiver.received(message)
            }
        })

        let client2Receiver = Receiver()

        client2.setReceiveHandler(.messages(timeTagMode: .ignore) { message, timeTag, host, port in
            guard !Task.isCancelled else { return }
            Task {
                await client2Receiver.received(message)
            }
        })

        // test server -> client 1

        let msgA = OSCMessage("/a")
        server.send(msgA, toClientIDs: [client1ID]) { clientID, error in Issue.record(error) }
        await wait(expect: { await client1Receiver.messages == [msgA] }, timeout: isStable ? 1.0 : 10.0)
        try await Task.sleep(seconds: isStable ? 0.5 : 5.0) // allow time for any errant messages
        #expect(await serverReceiver.messages == [])
        #expect(await client2Receiver.messages == [])

        await serverReceiver.reset()
        await client1Receiver.reset()
        await client2Receiver.reset()

        // test server -> client 2

        let msgB = OSCMessage("/b")
        server.send(msgB, toClientIDs: [client2ID]) { clientID, error in Issue.record(error) }
        await wait(expect: { await client2Receiver.messages == [msgB] }, timeout: isStable ? 1.0 : 10.0)
        try await Task.sleep(seconds: isStable ? 0.5 : 5.0) // allow time for any errant messages
        #expect(await serverReceiver.messages == [])
        #expect(await client1Receiver.messages == [])

        await serverReceiver.reset()
        await client1Receiver.reset()
        await client2Receiver.reset()

        // test server -> client 1 & 2

        let msgC = OSCMessage("/c")
        server.send(msgC, toClientIDs: [client1ID, client2ID]) { clientID, error in Issue.record(error) }
        await wait(expect: { await client1Receiver.messages == [msgC] }, timeout: isStable ? 1.0 : 10.0)
        await wait(expect: { await client2Receiver.messages == [msgC] }, timeout: isStable ? 1.0 : 10.0)
        try await Task.sleep(seconds: isStable ? 0.5 : 5.0) // allow time for any errant messages
        #expect(await serverReceiver.messages == [])

        await serverReceiver.reset()
        await client1Receiver.reset()
        await client2Receiver.reset()

        // test server -> "all connected clients"

        let msgD = OSCMessage("/d")
        server.send(msgD) { clientID, error in Issue.record(error) }
        await wait(expect: { await client1Receiver.messages == [msgD] }, timeout: isStable ? 1.0 : 10.0)
        await wait(expect: { await client2Receiver.messages == [msgD] }, timeout: isStable ? 1.0 : 10.0)
        try await Task.sleep(seconds: isStable ? 0.5 : 5.0) // allow time for any errant messages
        #expect(await serverReceiver.messages == [])

        await serverReceiver.reset()
        await client1Receiver.reset()
        await client2Receiver.reset()
    }
    // TODO: add tests for clients connecting, disconnecting, and reconnecting (check for memory leaks?)
}
