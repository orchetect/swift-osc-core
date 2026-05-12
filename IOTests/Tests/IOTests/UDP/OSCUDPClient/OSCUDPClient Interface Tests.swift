//
//  OSCUDPClient Interface Tests.swift
//  SwiftOSC Core • https://github.com/orchetect/swift-osc-core
//  © 2026 Steffan Andrews • Licensed under MIT License
//

#if canImport(Darwin) && !os(watchOS)

import Foundation
@testable import SwiftOSCIO
import Testing

@Suite(.serialized)
struct OSCUDPClient_Interface_Tests {
    /// Attempt to bind to a network interface, if one is present that can be used.
    @MainActor @Test
    func interfaceBinding_interfaceAddress() async throws {
        guard let interface = try ipV4NetworkDevice(forAddress: "127.0.0.1") else {
            withKnownIssue {
                Issue.record("No available network interfaces to test. Skipping test.")
            }
            return
        }
        
        print("Using interface \"\(interface.name)\" (\(interface.address))")
        
        // create a server to connect to
        let server = OSCUDPServer(port: nil, interface: interface.address)
        try server.start()
        
        // set up client
        let client = OSCUDPClient(localPort: nil, interface: interface.address)
        try client.start()
        client.stop()
    }
    
    /// Attempt to bind to a network interface, if one is present that can be used.
    @MainActor @Test
    func interfaceBinding_interfaceName() async throws {
        guard let interface = try ipV4NetworkDevice(forAddress: "127.0.0.1") else {
            withKnownIssue {
                Issue.record("No available network interfaces to test. Skipping test.")
            }
            return
        }
        
        print("Using interface \"\(interface.name)\" (\(interface.address))")
        
        // create a server to connect to
        let server = OSCUDPServer(port: nil, interface: interface.name)
        try server.start()
        
        // set up client
        let client = OSCUDPClient(localPort: nil, interface: interface.name)
        try client.start()
        client.stop()
    }

    /// Attempt to bind to an invalid network interface.
    @MainActor @Test
    func interfaceBinding_invalid() async throws {
        let interface = "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
        
        let client = OSCUDPClient(localPort: nil, interface: interface)
        
        #expect(throws: OSCUDPClientError.invalidInterface) {
            try client.start()
        }
    }
}

#endif
