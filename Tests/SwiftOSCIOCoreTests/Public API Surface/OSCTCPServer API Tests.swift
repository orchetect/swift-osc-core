//
//  OSCTCPServer API Tests.swift
//  SwiftOSC Core • https://github.com/orchetect/swift-osc-core
//  © 2026 Steffan Andrews • Licensed under MIT License
//

import SwiftOSCIOCore
import Testing

/// No functionality tests, just test that standardized API access compiles as expected.
@Suite
struct OSCTCPServer_API_Tests {
    private typealias OSCTCPServer = NoOpOSCTCPServer

    private static let message = OSCMessage("/test", values: [123, true])
    private static let bundle = OSCBundle(timeTag: .immediate(), [.message(message)])

    @Test
    func init_ProtocolDefined() {
        _ = OSCTCPServer(
            port: nil,
            interface: nil,
            isIPv6Enabled: true,
            framingMode: .osc1_1,
            queue: nil,
            receiveHandler: .messages { _, _, _, _ in }
        )

        _ = OSCTCPServer(
            port: nil,
            interface: nil,
            isIPv6Enabled: true,
            framingMode: .osc1_1,
            queue: nil,
            receiveHandler: .messages(timeTagMode: .osc1_0) { _, _, _, _ in }
        )
    }

    @Test
    func init_DefaultedOverloads() {
        _ = OSCTCPServer(port: nil)

        _ = OSCTCPServer(
            port: nil,
            interface: nil
        )

        _ = OSCTCPServer(
            port: nil,
            interface: nil,
            isIPv6Enabled: true
        )

        _ = OSCTCPServer(
            port: nil,
            interface: nil,
            isIPv6Enabled: true,
            framingMode: .osc1_1
        )

        _ = OSCTCPServer(
            port: nil,
            interface: nil,
            isIPv6Enabled: true,
            framingMode: .osc1_1,
            queue: nil
        )
    }

    @Test
    func propertyAccess() {
        let server = OSCTCPServer(port: nil)

        // read
        _ = server.localHost
        _ = server.localPort
        _ = server.interface
        _ = server.isStarted
        _ = server.framingMode
        _ = server.clients
        _ = server.isIPv6Enabled

        // set mutable properties
        server.isIPv6Enabled = true
    }

    @Test
    func methods() {
        let server = OSCTCPServer(port: nil)

        // start()
        try? server.start()

        // stop()
        server.stop()

        // send(OSCPacket)
        server.send(OSCPacket.bundle(Self.bundle))
        try? server.send(OSCPacket.bundle(Self.bundle), toClientID: 0)
        server.send(OSCPacket.bundle(Self.bundle), toClientIDs: [0])
        server.send(OSCPacket.bundle(Self.bundle), toClientIDs: [0]) { _, _ in }
        server.send(OSCPacket.message(Self.message))
        try? server.send(OSCPacket.message(Self.message), toClientID: 0)
        server.send(OSCPacket.message(Self.message), toClientIDs: [0])
        server.send(OSCPacket.message(Self.message), toClientIDs: [0]) { _, _ in }

        // send(OSCBundle)
        server.send(Self.bundle)
        try? server.send(Self.bundle, toClientID: 0)
        server.send(Self.bundle, toClientIDs: [0])
        server.send(Self.bundle, toClientIDs: [0]) { _, _ in }

        // send(OSCMessage)
        server.send(Self.message)
        try? server.send(Self.message, toClientID: 0)
        server.send(Self.message, toClientIDs: [0])
        server.send(Self.message, toClientIDs: [0]) { _, _ in }

        // disconnectClient()
        server.disconnectClient(clientID: 0)

        // setReceiveHandler { }
        server.setReceiveHandler(.messages { _, _, _, _ in })

        // setReceiveErrorHandler { }
        server.setReceiveErrorHandler { _, _, _, _ in }

        // setNotificationHandler { }
        server.setNotificationHandler { _ in }
    }
}
