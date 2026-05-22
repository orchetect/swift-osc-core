//
//  OSCUDPClient and OSCUDPServer Binding Tests.swift
//  SwiftOSC Core • https://github.com/orchetect/swift-osc-core
//  © 2026 Steffan Andrews • Licensed under MIT License
//

import Foundation
@testable import SwiftOSCIO
import Testing

extension SerializedTests {
    /// This creates a UDP server and client and:
    /// - checks that the "host" property of the OSC server callback for contains the correct resolved IP address
    /// - ensures the IP protocol mode (`isIPv6Enabled` property) is respected.
    /// - TODO: if/when both classes gain a `localHost` property, that also should be checked.
    ///
    /// This also tests that the UDP client is capable of self-starting gracefully if it is not manually started prior to sending.
    ///
    /// This test assumes that the system contains a hosts file entry for `localhost` that has both IPv4 and IPv6 IP addresses.
    @Suite
    struct OSCUDPClient_and_OSCUDPServer_Binding_Tests {
        @Test(arguments: [(false, false), (false, true), (true, false), (true, true)]) // IPv4 and IPv6 modes
        func onlineDefaultBinding(isIPv6Enabled: Bool, isClientManuallyStarted: Bool) async throws {
            // since default behavior for all OSC classes is to prefer IPv4 when possible,
            // when binding to "localhost", the IPv4 local address should always be used.
            // (unless an IPv6 interface is specified, of course -- which we are not testing here)
            let localIP = "127.0.0.1"
            
            typealias MessageDetails = (message: OSCMessage, host: String, port: UInt16)
            let serverReceiver = ItemReceiver<MessageDetails>()
            
            // create a server to connect to
            let server = OSCUDPServer(port: nil, isIPv6Enabled: isIPv6Enabled)
            
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
            
            // TODO: If `OSCUDPServerProtocol` gains a `localHost` property, check that it contains the correct resolved IP address as well
            
            // set up client
            let client = OSCUDPClient(localPort: nil, isIPv6Enabled: isIPv6Enabled)
            
            // start client
            if isClientManuallyStarted { try client.start() }
            defer { client.stop() }
            
            // ensure property reflects expected state
            #expect(client.isIPv6Enabled == isIPv6Enabled)
            
            // TODO: If `OSCUDPClientProtocol` gains a `localHost` property, check that it contains the correct resolved IP address as well
            
            // send a message from client to server
            try client.send(.message("/test"), to: "localhost", port: server.localPort)
            
            // ensure message was received and check its source IP address
            await wait(expect: { await !serverReceiver.items.isEmpty }, timeout: 5.0)
            #expect(await serverReceiver.items.count == 1)
            let serverMessageDetails = try await #require(serverReceiver.items.first)
            #expect(serverMessageDetails.host == localIP)
        }
    }
}
