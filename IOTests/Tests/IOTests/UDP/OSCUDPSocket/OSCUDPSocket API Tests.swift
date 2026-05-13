//
//  OSCUDPSocket API Tests.swift
//  SwiftOSC Core • https://github.com/orchetect/swift-osc-core
//  © 2026 Steffan Andrews • Licensed under MIT License
//

import SwiftOSCIO
import Testing

/// No functionality tests, just test that standardized API access compiles as expected.
@Suite
struct OSCUDPSocket_API_Tests {
    private static let message = OSCMessage("/test", values: [123, true])
    private static let bundle = OSCBundle(timeTag: .immediate(), [.message(message)])

    @Test
    func init_ProtocolDefined() {
        _ = OSCUDPSocket(
            localPort: nil,
            remoteHost: nil,
            remotePort: nil,
            interface: nil,
            timeTagMode: .ignore,
            isIPv4BroadcastEnabled: true,
            queue: nil,
            receiveHandler: { _, _, _, _ in }
        )
    }

    @Test
    func init_DefaultedOverloads() {
        _ = OSCUDPSocket()

        _ = OSCUDPSocket(
            localPort: 8000
        )

        _ = OSCUDPSocket(
            localPort: 8000,
            remoteHost: "nowhere"
        )

        _ = OSCUDPSocket(
            localPort: 8000,
            remoteHost: "nowhere",
            remotePort: 9000
        )

        _ = OSCUDPSocket(
            localPort: 8000,
            remoteHost: "nowhere",
            remotePort: 9000,
            interface: "en1"
        )

        _ = OSCUDPSocket(
            localPort: 8000,
            remoteHost: "nowhere",
            remotePort: 9000,
            interface: "en1",
            timeTagMode: .osc1_0
        )

        _ = OSCUDPSocket(
            localPort: 8000,
            remoteHost: "nowhere",
            remotePort: 9000,
            interface: "en1",
            timeTagMode: .osc1_0,
            isIPv4BroadcastEnabled: false
        )

        _ = OSCUDPSocket(
            localPort: 8000,
            remoteHost: "nowhere",
            remotePort: 9000,
            interface: "en1",
            timeTagMode: .osc1_0,
            isIPv4BroadcastEnabled: false,
            queue: nil
        )
    }

    @Test
    func propertyAccess() {
        let socket = OSCUDPSocket()

        // read
        _ = socket.timeTagMode
        _ = socket.remoteHost
        _ = socket.remotePort
        _ = socket.localPort
        _ = socket.interface
        _ = socket.isIPv4BroadcastEnabled
        _ = socket.isStarted

        // set mutable properties
        socket.timeTagMode = .osc1_0
        socket.remoteHost = "someplace"
        socket.remotePort = 8080
    }

    @Test
    func methods() {
        let socket = OSCUDPSocket()

        // start()
        try? socket.start()

        // stop()
        socket.stop()

        // send(OSCPacket)
        try? socket.send(OSCPacket.bundle(Self.bundle))
        try? socket.send(OSCPacket.bundle(Self.bundle), to: "nowhere")
        try? socket.send(OSCPacket.bundle(Self.bundle), to: "nowhere", port: 8000)
        try? socket.send(OSCPacket.bundle(Self.bundle), port: 8000)
        try? socket.send(OSCPacket.message(Self.message))
        try? socket.send(OSCPacket.message(Self.message), to: "nowhere")
        try? socket.send(OSCPacket.message(Self.message), to: "nowhere", port: 8000)
        try? socket.send(OSCPacket.message(Self.message), port: 8000)

        // send(OSCBundle)
        try? socket.send(Self.bundle)
        try? socket.send(Self.bundle, to: "nowhere")
        try? socket.send(Self.bundle, to: "nowhere", port: 8000)
        try? socket.send(Self.bundle, port: 8000)

        // send(OSCMessage)
        try? socket.send(Self.message)
        try? socket.send(Self.message, to: "nowhere")
        try? socket.send(Self.message, to: "nowhere", port: 8000)
        try? socket.send(Self.message, port: 8000)

        // setReceiveHandler { }
        socket.setReceiveHandler { _, _, _, _ in }
    }
}
