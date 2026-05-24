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
    /// - checks that the `host` parameter of the OSC receiver callbacks contain the correct resolved IP address
    /// - ensures the `localHost` property contains the correct resolved IP address
    /// - ensures the IP protocol mode (`isIPv6Enabled` property) is respected
    ///
    /// This test assumes that the system contains a hosts file entry for `localhost` that has both IPv4 and IPv6 IP addresses.
    @Suite
    struct OSCTCPClient_and_OSCTCPServer_Binding_Tests {
        @Test(arguments: [false, true]) // IPv4 and IPv6 modes
        func onlineDefaultBinding(isIPv6Enabled: Bool) async throws {
            let isStable = isSystemTimingStable()
            
            // since default behavior for all OSC classes is to prefer IPv4 when possible,
            // when binding to "localhost", the IPv4 local address should always be used.
            // (unless an IPv6 interface is specified, of course -- which we are not testing here)
            var localBinding = "0.0.0.0"
            var localIP = "127.0.0.1"
            
            #if os(Linux) || os(Android)
            // Linux (and probably Android) can't support a dual channel TCP server, so when enabling IPv6
            // we only use a single channel internally and bind it to the IPv6 wildcard address
            if isIPv6Enabled {
                localBinding = "::"
                localIP = "::ffff:127.0.0.1"
            }
            #else
            // silence mutable variable compiler warnings
            _ = localBinding
            _ = localIP
            #endif
            
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
            
            // ensure property reflects expected state
            #expect(server.localHost == nil)
            
            // start server
            print("Starting TCP server with IPv6 \(isIPv6Enabled ? "enabled" : "disabled")")
            try server.start()
            print("Started TCP server.")
            defer { server.stop() }
            
            await wait(expect: { server.isStarted }, timeout: isStable ? 0.5 : 5.0)
            
            // ensure property reflects expected state
            #expect(server.isIPv6Enabled == isIPv6Enabled)
            #expect(server.localHost == localBinding)
            
            // set up client
            let remoteHost = "localhost"
            let remotePort = server.localPort
            let client = OSCTCPClient(remoteHost: remoteHost, remotePort: remotePort, isIPv6Enabled: isIPv6Enabled)
            
            client.setReceiveHandler(.messages(timeTagMode: .ignore) { message, timeTag, host, port in
                Task { @TestActor in // must be serialized on a global actor to maintain received notification ordering
                    await clientReceiver.add((message: message, host: host, port: port))
                }
            })
            
            // ensure property reflects expected state
            #expect(client.localHost == nil)
            
            // start client
            print("Connecting TCP client to TCP server using address \(remoteHost):\(remotePort) with IPv6 \(isIPv6Enabled ? "enabled" : "disabled")")
            try client.connect()
            print("TCP client connected to TCP server.")
            defer { client.close() }
            
            // wait for connection
            await wait(expect: { !server.clients.isEmpty && client.isConnected }, timeout: isStable ? 0.5 : 5.0)
            
            // ensure properties reflect expected state
            #expect(client.isIPv6Enabled == isIPv6Enabled)
            #expect(client.localHost == localIP)
            
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
