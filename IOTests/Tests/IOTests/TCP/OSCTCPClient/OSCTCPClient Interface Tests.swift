//
//  OSCTCPClient Interface Tests.swift
//  SwiftOSC Core • https://github.com/orchetect/swift-osc-core
//  © 2026 Steffan Andrews • Licensed under MIT License
//

#if canImport(Darwin) && !os(watchOS)

import Foundation
@testable import SwiftOSCIO
import Testing

@Suite(.serialized)
struct OSCTCPClient_Interface_Tests {
    /// Attempt to bind to a network interface, if one is present that can be used.
    @MainActor @Test
    func interfaceBinding_interfaceAddress() async throws {
        guard let (_, interfaceAddress) = try ipV4NetworkDevice(forAddress: "127.0.0.1") else {
            withKnownIssue {
                Issue.record("No available network interfaces to test. Skipping test.")
            }
            return
        }
        
        let interface = interfaceAddress
        print("Using interface \"\(interface)\"")
        
        // create a server to connect to
        let server = OSCTCPServer(port: nil, interface: interface)
        #expect(server.interface == interface)
        try server.start()
        
        // set up client
        let client = OSCTCPClient(remoteHost: "127.0.0.1", remotePort: server.localPort, interface: interface)
        #expect(client.interface == interface)
        try client.connect()
        client.close()
    }
    
    /// Attempt to bind to a network interface, if one is present that can be used.
    @MainActor @Test
    func interfaceBinding_interfaceName() async throws {
        guard let (interfaceName, _) = try ipV4NetworkDevice(forAddress: "127.0.0.1") else {
            withKnownIssue {
                Issue.record("No available network interfaces to test. Skipping test.")
            }
            return
        }
        
        let interface = interfaceName
        print("Using interface \"\(interface)\"")
        
        // create a server to connect to
        let server = OSCTCPServer(port: nil, interface: interface)
        #expect(server.interface == interface)
        try server.start()
        
        // set up client
        let client = OSCTCPClient(remoteHost: "127.0.0.1", remotePort: server.localPort, interface: interface)
        #expect(client.interface == interface)
        try client.connect()
        client.close()
    }

    /// Attempt to bind to an invalid network interface.
    @MainActor @Test
    func interfaceBinding_invalid() async throws {
        let interface = "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
        
        let client = OSCTCPClient(remoteHost: "127.0.0.1", remotePort: 63076, interface: interface)
        
        #expect(throws: OSCIOError.invalidInterface) {
            try client.connect()
        }
    }
}

#endif
