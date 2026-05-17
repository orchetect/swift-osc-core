//
//  OSCTCPClient API Tests.swift
//  SwiftOSC Core • https://github.com/orchetect/swift-osc-core
//  © 2026 Steffan Andrews • Licensed under MIT License
//

import SwiftOSCIO
import Testing

extension SerializedTests {
    /// No functionality tests, just test that standardized API access compiles as expected.
    @Suite
    struct OSCTCPClient_API_Tests {
        private static let message = OSCMessage("/test", values: [123, true])
        private static let bundle = OSCBundle(timeTag: .immediate(), [.message(message)])
        
        @Test
        func init_ProtocolDefined() {
            _ = OSCTCPClient(
                remoteHost: "",
                remotePort: 8000,
                interface: "en1",
                framingMode: .osc1_1,
                queue: nil,
                receiveHandler: .messages { _, _, _, _ in }
            )
            
            _ = OSCTCPClient(
                remoteHost: "",
                remotePort: 8000,
                interface: "en1",
                framingMode: .osc1_1,
                queue: nil,
                receiveHandler: .messages(timeTagMode: .osc1_0) { _, _, _, _ in }
            )
            
            _ = OSCTCPClient(
                remoteHost: "",
                remotePort: 8000,
                interface: "en1",
                framingMode: .osc1_1,
                queue: nil,
                receiveHandler: .packets { _, _, _ in }
            )
        }
        
        @Test
        func init_DefaultedOverloads() {
            _ = OSCTCPClient(
                remoteHost: "",
                remotePort: 8000
            )
            
            _ = OSCTCPClient(
                remoteHost: "",
                remotePort: 8000,
                interface: nil
            )
            
            _ = OSCTCPClient(
                remoteHost: "",
                remotePort: 8000,
                interface: nil,
                framingMode: .osc1_1
            )
            
            _ = OSCTCPClient(
                remoteHost: "",
                remotePort: 8000,
                interface: nil,
                framingMode: .osc1_1,
                queue: nil
            )
        }
        
        @Test
        func propertyAccess() {
            let client = OSCTCPClient(
                remoteHost: "",
                remotePort: 8000
            )
            
            // read
            _ = client.remoteHost
            _ = client.remotePort
            _ = client.interface
            _ = client.isConnected
            _ = client.framingMode
            
            // set mutable properties
            // (none)
        }
        
        @Test
        func methods() {
            let client = OSCTCPClient(
                remoteHost: "",
                remotePort: 8000
            )
            
            // connect()
            try? client.connect() // defaulted timeout
            try? client.connect(timeout: 0.001)
            
            // close()
            client.close()
            
            // send(OSCPacket)
            try? client.send(OSCPacket.bundle(Self.bundle))
            try? client.send(OSCPacket.message(Self.message))
            
            // send(OSCBundle)
            try? client.send(Self.bundle)
            
            // send(OSCMessage)
            try? client.send(Self.message)
            
            // setReceiveHandler { }
            client.setReceiveHandler(.messages { _, _, _, _ in })
            
            // setReceiveErrorHandler { }
            client.setReceiveErrorHandler { _, _, _ , _ in }
            
            // setNotificationHandler { }
            client.setNotificationHandler { _ in }
        }
    }
}
