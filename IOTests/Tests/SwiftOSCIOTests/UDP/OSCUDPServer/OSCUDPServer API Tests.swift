//
//  OSCUDPServer API Tests.swift
//  SwiftOSC Core • https://github.com/orchetect/swift-osc-core
//  © 2026 Steffan Andrews • Licensed under MIT License
//

import SwiftOSCIO
import Testing

extension SerializedTests {
    /// No functionality tests, just test that standardized API access compiles as expected.
    @Suite
    struct OSCUDPServer_API_Tests {
        private static let message = OSCMessage("/test", values: [123, true])
        private static let bundle = OSCBundle(timeTag: .immediate(), [.message(message)])
        
        @Test
        func init_ProtocolDefined() {
            _ = OSCUDPServer(
                port: 8000,
                interface: "en1",
                isPortReuseEnabled: true,
                isIPv6Enabled: true,
                queue: nil,
                receiveHandler: .messages { _, _, _, _ in }
            )
            
            _ = OSCUDPServer(
                port: 8000,
                interface: "en1",
                isPortReuseEnabled: true,
                isIPv6Enabled: true,
                queue: nil,
                receiveHandler: .messages(timeTagMode: .osc1_0) { _, _, _, _ in }
            )
            
            _ = OSCUDPServer(
                port: 8000,
                interface: "en1",
                isPortReuseEnabled: true,
                isIPv6Enabled: true,
                queue: nil,
                receiveHandler: .packets { _, _, _ in }
            )
        }
        
        @Test
        func init_DefaultedOverloads() {
            _ = OSCUDPServer()
            
            _ = OSCUDPServer(
                port: 8000
            )
            
            _ = OSCUDPServer(
                port: 8000,
                interface: "en1"
            )
            
            _ = OSCUDPServer(
                port: 8000,
                interface: "en1",
                isPortReuseEnabled: true
            )
            
            _ = OSCUDPServer(
                port: 8000,
                interface: "en1",
                isPortReuseEnabled: true,
                isIPv6Enabled: true
            )
            
            _ = OSCUDPServer(
                port: 8000,
                interface: "en1",
                isPortReuseEnabled: true,
                isIPv6Enabled: true,
                queue: nil
            )
        }
        
        @Test
        func propertyAccess() {
            let server = OSCUDPServer()
            
            // read
            _ = server.localPort
            _ = server.interface
            _ = server.isPortReuseEnabled
            _ = server.isIPv6Enabled
            _ = server.isStarted
            
            // set mutable properties
            server.isPortReuseEnabled = true
            server.isIPv6Enabled = true
        }
        
        @Test
        func methods() {
            let server = OSCUDPServer()
            
            // start()
            try? server.start()
            
            // stop()
            server.stop()
            
            // setReceiveHandler { }
            server.setReceiveHandler(.messages { _, _, _, _ in })
            
            // setReceiveErrorHandler { }
            server.setReceiveErrorHandler { _, _, _ , _ in }
        }
    }
}
