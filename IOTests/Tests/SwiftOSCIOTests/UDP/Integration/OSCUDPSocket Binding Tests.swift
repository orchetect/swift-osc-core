//
//  OSCUDPSocket Binding Tests.swift
//  SwiftOSC Core • https://github.com/orchetect/swift-osc-core
//  © 2026 Steffan Andrews • Licensed under MIT License
//

import Foundation
@testable import SwiftOSCIO
import Testing

extension SerializedTests {
    /// This forms a socket and:
    /// - checks that the `host` parameter of the OSC receiver contains the correct resolved IP address
    /// - ensures the `localHost` property contains the correct resolved IP address
    /// - ensures the IP protocol mode (`isIPv6Enabled` property) is respected
    ///
    /// This test assumes that the system contains a hosts file entry for `localhost` that has both IPv4 and IPv6 IP addresses.
    @Suite
    struct OSCUDPSocket_Binding_Tests {
        @Test(arguments: [false, true]) // IPv4 and IPv6 modes
        func defaultBinding(isIPv6Enabled: Bool) async throws {
            // since default behavior for all OSC classes is to prefer IPv4 when possible,
            // when binding to "localhost", the IPv4 local address should always be used.
            // (unless an IPv6 interface is specified, of course -- which we are not testing here)
            let localBinding = "0.0.0.0"
            let localIP = "127.0.0.1"
            
            typealias MessageDetails = (message: OSCMessage, host: String, port: UInt16)
            let socketReceiver = ItemReceiver<MessageDetails>()
            
            // create a socket
            let socket = OSCUDPSocket(isIPv6Enabled: isIPv6Enabled)
            
            socket.setReceiveHandler(.messages(timeTagMode: .ignore) { message, timeTag, host, port in
                Task { @TestActor in // must be serialized on a global actor to maintain received notification ordering
                    await socketReceiver.add((message: message, host: host, port: port))
                }
            })
            
            // ensure property reflects expected state
            #expect(socket.localHost == nil)
            
            // start socket
            try socket.start()
            defer { socket.stop() }
            await wait(expect: { socket.isStarted }, timeout: 5.0)
            
            // ensure property reflects expected state
            #expect(socket.isIPv6Enabled == isIPv6Enabled)
            #expect(socket.localHost == localBinding)
            
            // set up client
            let client = OSCUDPClient(localPort: nil, isIPv6Enabled: isIPv6Enabled)
            
            // start client
            try client.start()
            defer { client.stop() }
            
            // wait for connection
            await wait(expect: { client.isStarted }, timeout: 5.0)
            
            // ensure property reflects expected state
            #expect(client.isIPv6Enabled == isIPv6Enabled)
            
            // send a message from client to socket
            try client.send(.message("/test"), to: "localhost", port: socket.localPort)
            
            // ensure message was received and check its source IP address
            await wait(expect: { await !socketReceiver.items.isEmpty }, timeout: 5.0)
            #expect(await socketReceiver.items.count == 1)
            let socketMessageDetails = try await #require(socketReceiver.items.first)
            #expect(socketMessageDetails.host == localIP)
        }
    }
}
