//
//  OSCUDPClient Interface Tests.swift
//  SwiftOSC Core • https://github.com/orchetect/swift-osc-core
//  © 2026 Steffan Andrews • Licensed under MIT License
//

import Foundation
@testable import SwiftOSCIO
import Testing

extension SerializedTests {
    @Suite
    struct OSCUDPClient_Interface_Tests {
        /// Attempt to bind to a network interface, if one is present that can be used.
        @Test(arguments: ["127.0.0.1", "::1"]) // IPv4 and IPv6 local addresses
        func interfaceBinding_interfaceAddress(localIP: String) throws {
            guard let (_, interfaceAddress) = try networkDevice(
                protocols: [.inet, .inet6],
                includeLoopback: true,
                forAddress: localIP
            ) else {
                withKnownIssue {
                    Issue.record("No available network interfaces to test. Skipping test.")
                }
                return
            }
            
            let interface = interfaceAddress
            print("Using interface \"\(interface)\"")
            
            // create a server to connect to
            let server = OSCUDPServer(port: nil, interface: interface)
            #expect(server.interface == interface)
            try server.start()
            
            // set up client
            let client = OSCUDPClient(localPort: nil, interface: interface)
            #expect(client.interface == interface)
            try client.start()
            client.stop()
        }
        
        /// Attempt to bind to a network interface, if one is present that can be used.
        @Test(arguments: ["127.0.0.1", "::1"]) // IPv4 and IPv6 local addresses
        func interfaceBinding_interfaceName(localIP: String) throws {
            guard let (interfaceName, _) = try networkDevice(
                protocols: [.inet, .inet6],
                includeLoopback: true,
                forAddress: localIP
            ) else {
                withKnownIssue {
                    Issue.record("No available network interfaces to test. Skipping test.")
                }
                return
            }
            
            let interface = interfaceName
            print("Using interface \"\(interface)\"")
            
            // create a server to connect to
            let server = OSCUDPServer(port: nil, interface: interface)
            #expect(server.interface == interface)
            try server.start()
            
            // set up client
            let client = OSCUDPClient(localPort: nil, interface: interface)
            #expect(client.interface == interface)
            try client.start()
            client.stop()
        }
        
        /// Attempt to bind to an invalid network interface.
        @Test
        func interfaceBinding_invalid() throws {
            let interface = "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
            
            let client = OSCUDPClient(localPort: nil, interface: interface)
            
            #expect(throws: OSCIOError.invalidInterface) {
                try client.start()
            }
        }
    }
}
