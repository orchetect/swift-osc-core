//
//  OSCTCPClient and OSCTCPServer Binding Tests.swift
//  SwiftOSC Core • https://github.com/orchetect/swift-osc-core
//  © 2026 Steffan Andrews • Licensed under MIT License
//

import Foundation
@testable import SwiftOSCIO
import Testing

extension SerializedTests {
    /// This forms a TCP server/client connection and:
    /// - checks that the "host" property of the OSC receiver callback for both classes contains the correct resolved IP address
    /// - ensures the IP protocol mode (`isIPv6Enabled` property) is respected.
    /// - TODO: if/when both classes gain a `localHost` property, that also should be checked.
    ///
    /// This test assumes that the system contains a hosts file entry for `localhost` that has both IPv4 and IPv6 IP addresses.
    @Suite
    struct OSCTCPClient_and_OSCTCPServer_Binding_Tests {
        @Test(arguments: [false, true]) // IPv4 and IPv6 modes
        func onlineDefaultBinding(isIPv6Enabled: Bool) async throws {
            // since default behavior for all OSC classes is to prefer IPv4 when possible,
            // when binding to "localhost", the IPv4 local address should always be used.
            // (unless an IPv6 interface is specified, of course -- which we are not testing here)
            let localIP = "127.0.0.1"
            
            typealias MessageDetails = (message: OSCMessage, host: String, port: UInt16)
            let serverReceiver = ItemReceiver<MessageDetails>()
            let clientReceiver = ItemReceiver<MessageDetails>()
            
            // create a server to connect to
            let server = OSCTCPServer(port: nil, isIPv6Enabled: isIPv6Enabled)
            
            server.setReceiveHandler(.messages(timeTagMode: .ignore) { message, timeTag, host, port in
                Task { @TestActor in // must be serialized on a global actor to maintain received notification ordering
                    await serverReceiver.add((message: message, host: host, port: port))
                }
            })
            
            // start server
            try server.start()
            defer { server.stop() }
            await wait(expect: { server.isStarted }, timeout: 5.0)
            
            // ensure property reflects expected state
            #expect(server.isIPv6Enabled == isIPv6Enabled)
            
            // TODO: If `OSCTCPServerProtocol` gains a `localHost` property, check that it contains the correct resolved IP address as well
            
            // set up client
            let client = OSCTCPClient(remoteHost: "localhost", remotePort: server.localPort, isIPv6Enabled: isIPv6Enabled)
            
            client.setReceiveHandler(.messages(timeTagMode: .ignore) { message, timeTag, host, port in
                Task { @TestActor in // must be serialized on a global actor to maintain received notification ordering
                    await clientReceiver.add((message: message, host: host, port: port))
                }
            })
            
            // start client
            try client.connect()
            defer { client.close() }
            
            // wait for connection
            await wait(expect: { client.isConnected }, timeout: 5.0)
            
            // ensure property reflects expected state
            #expect(client.isIPv6Enabled == isIPv6Enabled)
            
            // TODO: If `OSCTCPClientProtocol` gains a `localHost` property, check that it contains the correct resolved IP address as well
            
            // send a message from server to client
            server.send(.message("/test"), toClientIDs: nil) { clientID, error in
                // No error should be thrown
                Issue.record(error)
            }
            
            // ensure message was received and check its source IP address
            await wait(expect: { await !clientReceiver.items.isEmpty }, timeout: 5.0)
            #expect(await clientReceiver.items.count == 1)
            let clientMessageDetails = try await #require(clientReceiver.items.first)
            #expect(clientMessageDetails.host == localIP)
            
            // send a message from client to server
            try client.send(.message("/test"))
            
            // ensure message was received and check its source IP address
            await wait(expect: { await !serverReceiver.items.isEmpty }, timeout: 5.0)
            #expect(await serverReceiver.items.count == 1)
            let serverMessageDetails = try await #require(serverReceiver.items.first)
            #expect(serverMessageDetails.host == localIP)
        }
    }
}
