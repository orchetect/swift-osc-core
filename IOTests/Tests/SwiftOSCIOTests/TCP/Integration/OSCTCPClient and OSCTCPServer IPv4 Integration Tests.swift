//
//  OSCTCPClient and OSCTCPServer IPv4 Integration Tests.swift
//  SwiftOSC Core • https://github.com/orchetect/swift-osc-core
//  © 2026 Steffan Andrews • Licensed under MIT License
//

import Foundation
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
    struct OSCTCPClient_and_OSCTCPServer_IPv4_Integration_Tests {
        /// Online stress-test (IPv4) to ensure a large volume of OSC packets are received and dispatched in order.
        /// - This test is repeated for each TCP framing mode.
        /// - This also tests that when passing local port 0 to server's init, after calling `start()` the `localPort`
        ///   property is then populated with the system-assigned port.
        @Test(.serialized, arguments: OSCTCPFramingMode.allCases)
        func onlineStressTest(framingMode: OSCTCPFramingMode) async throws {
            let isStable = isSystemTimingStable()
            
            // setup server
            
            // binding to port 0 or nil will cause the system to assign a random available port
            let server = OSCTCPServer(port: nil, framingMode: framingMode)
            try await Task.sleep(seconds: isStable ? 0.1 : 5.0)
            
            // sanity check - IPv6 should be disabled by default, as per the OSCTCPServerProtocol spec.
            #expect(!server.isIPv6Enabled)
            
            try server.start()
            try await Task.sleep(seconds: isStable ? 0.5 : 5.0)
            
            // cleanup when test case exists so no open sockets hang or interfere with other test cases
            defer { server.stop() }
            
            print("Using server listen port \(server.localPort)")
            
            // setup client
            // (must be done after calling start on server so we have a non-zero local server port to use)
            
            let client = OSCTCPClient(remoteHost: "127.0.0.1", remotePort: server.localPort, framingMode: framingMode)
            try await Task.sleep(seconds: isStable ? 0.1 : 5.0)
            
            // sanity check - IPv6 should be disabled by default, as per the OSCTCPClientProtocol spec.
            #expect(!client.isIPv6Enabled)
            
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
                Task { @TestActor in // must be serialized on a global actor to maintain received message ordering
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
                Task { @TestActor in // must be serialized on a global actor to maintain received message ordering
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
        
        /// Online test (IPv4) to check that connections are added when an incoming connection is made,
        /// and check that connections are removed when a connection is closed remotely.
        @Test
        func onlineClientConnectDisconnect() async throws {
            let isStable = isSystemTimingStable()
            
            // setup server
            
            // binding to port 0 or nil will cause the system to assign a random available port
            let server = OSCTCPServer(port: nil, framingMode: .osc1_1)
            try await Task.sleep(seconds: isStable ? 0.1 : 5.0)
            
            // sanity check - IPv6 should be disabled by default, as per the OSCTCPServerProtocol spec.
            #expect(!server.isIPv6Enabled)
            
            try server.start()
            try await Task.sleep(seconds: isStable ? 0.5 : 5.0)
            
            // cleanup when test case exists so no open sockets hang or interfere with other test cases
            defer { server.stop() }
            
            print("Using server listen port \(server.localPort)")
            
            // setup client 1
            // (must be done after calling start on server so we have a non-zero local server port to use)
            
            let client1 = OSCTCPClient(remoteHost: "127.0.0.1", remotePort: server.localPort, framingMode: .osc1_1)
            try await Task.sleep(seconds: isStable ? 0.1 : 5.0)
            
            // sanity check - IPv6 should be disabled by default, as per the OSCTCPClientProtocol spec.
            #expect(!client1.isIPv6Enabled)
            
            try client1.connect()
            try await Task.sleep(seconds: isStable ? 0.5 : 5.0)
            
            // sanity check - IPv6 should be disabled by default, as per the OSCTCPClientProtocol spec.
            #expect(!client1.isIPv6Enabled)
            
            #expect(server.clients.count == 1)
            
            // setup client 2
            // (must be done after calling start on server so we have a non-zero local server port to use)
            
            let client2 = OSCTCPClient(remoteHost: "127.0.0.1", remotePort: server.localPort, framingMode: .osc1_1)
            try await Task.sleep(seconds: isStable ? 0.1 : 5.0)
            
            // sanity check - IPv6 should be disabled by default, as per the OSCTCPClientProtocol spec.
            #expect(!client2.isIPv6Enabled)
            
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
        
        /// Online test (IPv4) to check that the expected notification callbacks are made when a client
        /// gracefully disconnects itself from a server.
        @Test
        func onlineClientGracefulDisconnectNotifications() async throws {
            let isStable = isSystemTimingStable()
            
            let serverReceiver = ItemReceiver<OSCTCPServer.Notification>()
            let clientReceiver = ItemReceiver<OSCTCPClient.Notification>()
            
            // setup server
            
            // binding to port 0 or nil will cause the system to assign a random available port
            let server = OSCTCPServer(port: nil, framingMode: .osc1_1)
            try await Task.sleep(seconds: isStable ? 0.1 : 5.0)
            
            // sanity check - IPv6 should be disabled by default, as per the OSCTCPServerProtocol spec.
            #expect(!server.isIPv6Enabled)
            
            server.setNotificationHandler { [weak serverReceiver] notification in
                Task { @TestActor in // must be serialized on a global actor to maintain received notification ordering
                    await serverReceiver?.add(notification)
                }
            }
            
            try server.start()
            try await Task.sleep(seconds: isStable ? 0.5 : 5.0)
            
            // cleanup when test case exists so no open sockets hang or interfere with other test cases
            defer { server.stop() }
            
            print("Using server listen port \(server.localPort)")
            
            #expect(await serverReceiver.items.isEmpty)
            
            // setup client 1
            // (must be done after calling start on server so we have a non-zero local server port to use)
            
            let client = OSCTCPClient(remoteHost: "127.0.0.1", remotePort: server.localPort, framingMode: .osc1_1)
            try await Task.sleep(seconds: isStable ? 0.1 : 5.0)
            
            // sanity check - IPv6 should be disabled by default, as per the OSCTCPClientProtocol spec.
            #expect(!client.isIPv6Enabled)
            
            client.setNotificationHandler { [weak clientReceiver] notification in
                Task { @TestActor in // must be serialized on a global actor to maintain received notification ordering
                    await clientReceiver?.add(notification)
                }
            }
            
            // connect to server
            try client.connect()
            try await Task.sleep(seconds: isStable ? 0.5 : 5.0)
            
            await wait(expect: { await !serverReceiver.items.isEmpty }, timeout: isStable ? 2.0 : 10.0)
            await wait(expect: { await !clientReceiver.items.isEmpty }, timeout: isStable ? 2.0 : 10.0)
            
            let clientID = server.clients.first!.key
            let clientRemoteHost = "127.0.0.1"
            let clientRemotePort = client.core.tcpSocket.localPort // TODO: could change to `client.localPort` once implemented
            
            // check received notifications
            #expect(await serverReceiver.items == [
                .connected(remoteHost: clientRemoteHost, remotePort: clientRemotePort, clientID: clientID)
            ])
            #expect(await clientReceiver.items == [
                .connected
            ])
            await serverReceiver.reset()
            await clientReceiver.reset()
            
            // have client close its own connection gracefully
            client.close()
            try await Task.sleep(seconds: isStable ? 0.5 : 5.0)
            
            // check received notifications
            #expect(await serverReceiver.items == [
                .disconnected(remoteHost: "127.0.0.1", remotePort: clientRemotePort, clientID: clientID, error: nil)
            ])
            #expect(await clientReceiver.items == [
                .disconnected(error: nil)
            ])
            await serverReceiver.reset()
            await clientReceiver.reset()
            
            // cleanup
            server.stop()
        }
        
        /// Online test (IPv4) to check that the expected notification callbacks are made when a server gracefully
        /// closes a connection to a connected remote client.
        @Test
        func onlineServerGracefulDisconnectNotification() async throws {
            let isStable = isSystemTimingStable()
            
            let serverReceiver = ItemReceiver<OSCTCPServer.Notification>()
            let clientReceiver = ItemReceiver<OSCTCPClient.Notification>()
            
            // setup server
            
            // binding to port 0 or nil will cause the system to assign a random available port
            let server = OSCTCPServer(port: nil, framingMode: .osc1_1)
            try await Task.sleep(seconds: isStable ? 0.1 : 5.0)
            
            // sanity check - IPv6 should be disabled by default, as per the OSCTCPServerProtocol spec.
            #expect(!server.isIPv6Enabled)
            
            server.setNotificationHandler { [weak serverReceiver] notification in
                Task { @TestActor in // must be serialized on a global actor to maintain received notification ordering
                    await serverReceiver?.add(notification)
                }
            }
            
            try server.start()
            try await Task.sleep(seconds: isStable ? 0.5 : 5.0)
            
            // cleanup when test case exists so no open sockets hang or interfere with other test cases
            defer { server.stop() }
            
            print("Using server listen port \(server.localPort)")
            
            #expect(await serverReceiver.items.isEmpty)
            
            // setup client 1
            // (must be done after calling start on server so we have a non-zero local server port to use)
            
            let client = OSCTCPClient(remoteHost: "127.0.0.1", remotePort: server.localPort, framingMode: .osc1_1)
            try await Task.sleep(seconds: isStable ? 0.1 : 5.0)
            
            // sanity check - IPv6 should be disabled by default, as per the OSCTCPClientProtocol spec.
            #expect(!client.isIPv6Enabled)
            
            client.setNotificationHandler { [weak clientReceiver] notification in
                Task { @TestActor in // must be serialized on a global actor to maintain received notification ordering
                    await clientReceiver?.add(notification)
                }
            }
            
            try client.connect()
            try await Task.sleep(seconds: isStable ? 0.5 : 5.0)
            
            await wait(expect: { await !serverReceiver.items.isEmpty }, timeout: isStable ? 2.0 : 10.0)
            await wait(expect: { await !clientReceiver.items.isEmpty }, timeout: isStable ? 2.0 : 10.0)
            
            let clientID = server.clients.first!.key
            let clientRemoteHost = "127.0.0.1"
            let clientRemotePort = client.core.tcpSocket.localPort // TODO: could change to `client.localPort` once implemented
            
            // check received notifications
            #expect(await serverReceiver.items == [
                .connected(remoteHost: clientRemoteHost, remotePort: clientRemotePort, clientID: clientID)
            ])
            #expect(await clientReceiver.items == [
                .connected
            ])
            await serverReceiver.reset()
            await clientReceiver.reset()
            
            server.disconnectClient(clientID: clientID)
            try await Task.sleep(seconds: isStable ? 0.5 : 5.0)
            
            // check received notifications
            #expect(await serverReceiver.items == [
                .disconnected(remoteHost: "127.0.0.1", remotePort: clientRemotePort, clientID: clientID, error: nil)
            ])
            #expect(await clientReceiver.items == [
                .disconnected(error: nil)
            ])
            await serverReceiver.reset()
            await clientReceiver.reset()
            
            // cleanup
            client.close()
        }
        
        /// Online test (IPv4) of starting TCP server, then stopping it, then restarting it again.
        @Test
        func onlineStartStopServer() async throws {
            let isStable = isSystemTimingStable()
            
            // binding to port 0 or nil will cause the system to assign a random available port
            let server = OSCTCPServer(port: nil, framingMode: .osc1_1)
            try await Task.sleep(seconds: isStable ? 0.1 : 5.0)
            
            // sanity check - IPv6 should be disabled by default, as per the OSCTCPServerProtocol spec.
            #expect(!server.isIPv6Enabled)
            
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
            
            // sanity check - IPv6 should be disabled by default, as per the OSCTCPClientProtocol spec.
            #expect(!client1.isIPv6Enabled)
            
            try client1.connect()
            try await Task.sleep(seconds: isStable ? 0.5 : 5.0)
            
            // sanity check - IPv6 should be disabled by default, as per the OSCTCPClientProtocol spec.
            #expect(!client1.isIPv6Enabled)
            
            #expect(server.clients.count == 1)
        }
        
        /// Online test (IPv4) of multiple connected clients.
        @Test
        func onlineMultipleClientTest() async throws {
            let isStable = isSystemTimingStable()
            let framingMode: OSCTCPFramingMode = .osc1_1
            
            // setup server
            
            // binding to port 0 or nil will cause the system to assign a random available port
            let server = OSCTCPServer(port: nil, framingMode: framingMode)
            try await Task.sleep(seconds: isStable ? 0.1 : 5.0)
            
            // sanity check - IPv6 should be disabled by default, as per the OSCTCPServerProtocol spec.
            #expect(!server.isIPv6Enabled)
            
            try server.start()
            try await Task.sleep(seconds: isStable ? 0.5 : 5.0)
            
            print("Using server listen port \(server.localPort)")
            
            // setup clients
            // (must be done after calling start on server so we have a non-zero local server port to use)
            
            // client 1
            
            let client1 = OSCTCPClient(remoteHost: "127.0.0.1", remotePort: server.localPort, framingMode: framingMode)
            try await Task.sleep(seconds: isStable ? 0.1 : 5.0)
            
            // sanity check - IPv6 should be disabled by default, as per the OSCTCPClientProtocol spec.
            #expect(!client1.isIPv6Enabled)
            
            try client1.connect()
            try await Task.sleep(seconds: isStable ? 0.5 : 5.0)
            
            #expect(server.clients.count == 1)
            let client1ID = try #require(server.clients.first?.key)
            
            // client 2
            
            let client2 = OSCTCPClient(remoteHost: "127.0.0.1", remotePort: server.localPort, framingMode: framingMode)
            try await Task.sleep(seconds: isStable ? 0.1 : 5.0)
            
            // sanity check - IPv6 should be disabled by default, as per the OSCTCPClientProtocol spec.
            #expect(!client2.isIPv6Enabled)
            
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
                Task { @TestActor in // must be serialized on a global actor to maintain received message ordering
                    await serverReceiver.received(message)
                }
            })
            
            let client1Receiver = Receiver()
            
            client1.setReceiveHandler(.messages(timeTagMode: .ignore) { message, timeTag, host, port in
                guard !Task.isCancelled else { return }
                Task { @TestActor in // must be serialized on a global actor to maintain received message ordering
                    await client1Receiver.received(message)
                }
            })
            
            let client2Receiver = Receiver()
            
            client2.setReceiveHandler(.messages(timeTagMode: .ignore) { message, timeTag, host, port in
                guard !Task.isCancelled else { return }
                Task { @TestActor in // must be serialized on a global actor to maintain received message ordering
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
    }
}
