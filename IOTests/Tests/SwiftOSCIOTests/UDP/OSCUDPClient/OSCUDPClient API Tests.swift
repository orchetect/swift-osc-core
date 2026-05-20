//
//  OSCUDPClient API Tests.swift
//  SwiftOSC Core • https://github.com/orchetect/swift-osc-core
//  © 2026 Steffan Andrews • Licensed under MIT License
//

import SwiftOSCIO
import Testing

extension SerializedTests {
    /// No functionality tests, just test that standardized API access compiles as expected.
    @Suite
    struct OSCUDPClient_API_Tests {
        private static let message = OSCMessage("/test", values: [123, true])
        private static let bundle = OSCBundle(timeTag: .immediate(), [.message(message)])
        
        @Test
        func init_ProtocolDefined() {
            _ = OSCUDPClient()
        }
        
        @Test
        func initParameterized_ProtocolDefined() {
            _ = OSCUDPClient(
                localPort: 8001,
                interface: "en1",
                isPortReuseEnabled: true,
                isIPv4BroadcastEnabled: true,
                isIPv6Enabled: true
            )
        }
        
        @Test
        func initParameterized_DefaultedOverloads() {
            _ = OSCUDPClient(
                localPort: 8002
            )
            
            _ = OSCUDPClient(
                localPort: 8002,
                interface: nil
            )
            
            _ = OSCUDPClient(
                localPort: 8003,
                interface: nil,
                isPortReuseEnabled: true
            )
            
            _ = OSCUDPClient(
                localPort: 8004,
                interface: nil,
                isPortReuseEnabled: true,
                isIPv4BroadcastEnabled: true
            )
            
            _ = OSCUDPClient(
                localPort: 8004,
                interface: nil,
                isPortReuseEnabled: true,
                isIPv4BroadcastEnabled: true,
                isIPv6Enabled: true
            )
        }
        
        @Test
        func propertyAccess() {
            let client = OSCUDPClient()
            
            // read
            _ = client.localPort
            _ = client.interface
            _ = client.isPortReuseEnabled // mutable
            _ = client.isIPv4BroadcastEnabled // mutable
            _ = client.isIPv6Enabled
            _ = client.isStarted
            
            // set mutable properties
            client.isPortReuseEnabled = true
            client.isIPv4BroadcastEnabled = true
            client.isIPv6Enabled = true
        }
        
        @Test
        func methods() {
            let client = OSCUDPClient()
            
            // start()
            try? client.start()
            
            // stop()
            client.stop()
            
            // send(OSCPacket)
            try? client.send(OSCPacket.bundle(Self.bundle), to: "nowhere", port: 8000)
            try? client.send(OSCPacket.message(Self.message), to: "nowhere", port: 8000)
            
            // send(OSCBundle)
            try? client.send(Self.bundle, to: "nowhere", port: 8000)
            
            // send(OSCMessage)
            try? client.send(Self.message, to: "nowhere", port: 8000)
        }
    }
}
