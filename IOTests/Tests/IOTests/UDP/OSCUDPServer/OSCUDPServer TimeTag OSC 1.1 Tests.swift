//
//  OSCUDPServer TimeTag OSC 1.1 Tests.swift
//  SwiftOSC Core • https://github.com/orchetect/swift-osc-core
//  © 2026 Steffan Andrews • Licensed under MIT License
//

@testable import SwiftOSCIO
import Testing

@Suite
struct OSCUDPServer_TimeTag_OSC1_1_Tests {
    @Test
    func defaultTimeTag() async throws {
        try await confirmation(expectedCount: 1) { confirmation in
            let server = OSCUDPServer(timeTagMode: .ignore)

            server.setReceiveHandler { _, _, _, _ in
                confirmation()
            }

            let bundle = OSCBundle([
                .message("/test", values: [Int32(123)])
            ])

            server.core.handle(packet: .bundle(bundle), remoteHost: "127.0.0.1", remotePort: 8000)

            try await Task.sleep(seconds: 0.5)
        }
    }

    @Test
    func immediate() async throws {
        try await confirmation(expectedCount: 1) { confirmation in
            let server = OSCUDPServer(timeTagMode: .ignore)

            server.setReceiveHandler { _, _, _, _ in
                confirmation()
            }

            let bundle = OSCBundle(
                timeTag: .immediate(),
                [.message("/test", values: [Int32(123)])]
            )

            server.core.handle(packet: .bundle(bundle), remoteHost: "127.0.0.1", remotePort: 8000)

            try await Task.sleep(seconds: 0.5)
        }
    }

    @Test
    func now() async throws {
        try await confirmation(expectedCount: 1) { confirmation in
            let server = OSCUDPServer(timeTagMode: .ignore)

            server.setReceiveHandler { _, _, _, _ in
                confirmation()
            }

            let bundle = OSCBundle(
                timeTag: .now(),
                [.message("/test", values: [Int32(123)])]
            )

            server.core.handle(packet: .bundle(bundle), remoteHost: "127.0.0.1", remotePort: 8000)

            try await Task.sleep(seconds: 0.5)
        }
    }

    @Test
    func oneSecondInFuture() async throws {
        try await confirmation(expectedCount: 1) { confirmation in
            let server = OSCUDPServer(timeTagMode: .ignore)

            server.setReceiveHandler { _, _, _, _ in
                confirmation()
            }

            let bundle = OSCBundle(
                timeTag: .timeIntervalSinceNow(1.0),
                [.message("/test", values: [Int32(123)])]
            )

            server.core.handle(packet: .bundle(bundle), remoteHost: "127.0.0.1", remotePort: 8000)

            try await Task.sleep(seconds: 0.5)
        }
    }

    @Test
    func past() async throws {
        try await confirmation(expectedCount: 1) { confirmation in
            let server = OSCUDPServer(timeTagMode: .ignore)

            server.setReceiveHandler { _, _, _, _ in
                confirmation()
            }

            let bundle = OSCBundle(
                timeTag: .timeIntervalSinceNow(-1.0),
                [.message("/test", values: [Int32(123)])]
            )

            server.core.handle(packet: .bundle(bundle), remoteHost: "127.0.0.1", remotePort: 8000)

            try await Task.sleep(seconds: 0.5)
        }
    }
}
