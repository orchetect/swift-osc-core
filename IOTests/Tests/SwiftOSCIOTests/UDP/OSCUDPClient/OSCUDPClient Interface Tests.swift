//
//  OSCUDPClient Interface Tests.swift
//  SwiftOSC Core • https://github.com/orchetect/swift-osc-core
//  © 2026 Steffan Andrews • Licensed under MIT License
//

import Foundation
@testable import SwiftOSCIO
import Testing

extension SerializedTests {
    /// These tests cover both IPv4 and IPv6.
    @Suite
    struct OSCUDPClient_Interface_Tests {
        /// Attempt to bind to a network interface, if one is present that can be used.
        @Test(arguments: ["127.0.0.1", "::1"]) // IPv4 and IPv6 local addresses
        func interfaceBinding_interfaceAddress(toLocalIP localIP: String) throws {
            let isIPv6 = localIP.contains(":")
            
            guard let (_, interfaceAddress) = try networkDevice(
                protocols: [isIPv6 ? .inet6 : .inet],
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
            let server = OSCUDPServer(port: nil, interface: interface, isIPv6Enabled: isIPv6)
            #expect(server.interface == interface)
            try server.start()
            defer { server.stop() }
            
            // set up client
            let client = OSCUDPClient(localPort: nil, interface: interface, isIPv6Enabled: isIPv6)
            #expect(client.interface == interface)
            try client.start()
            client.stop()
        }
        
        /// Attempt to bind to a network interface, if one is present that can be used.
        @Test(arguments: ["127.0.0.1", "::1"]) // IPv4 and IPv6 local addresses
        func interfaceBinding_interfaceName(toInterfaceNameOfLocalIP localIP: String) throws {
            let isIPv6 = localIP.contains(":")
            
            guard let (interfaceName, _) = try networkDevice(
                protocols: [isIPv6 ? .inet6 : .inet],
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
            let server = OSCUDPServer(port: nil, interface: interface, isIPv6Enabled: isIPv6)
            #expect(server.interface == interface)
            try server.start()
            defer { server.stop() }
            
            // set up client
            let client = OSCUDPClient(localPort: nil, interface: interface, isIPv6Enabled: isIPv6)
            #expect(client.interface == interface)
            try client.start()
            client.stop()
        }
        
        /// Attempt to bind to a wildcard address via the `interface` parameter.
        @Test(arguments: [("0.0.0.0", "127.0.0.1", false), ("::", "::1", true)]) // IPv4 and IPv6
        func interfaceBinding_wildcardAddress(wildcardAddress: String, localIP: String, isIPv6: Bool) throws {
            let interface = wildcardAddress
            print("Using interface \"\(interface)\"")
            
            // create a server to connect to
            let server = OSCUDPServer(port: nil, interface: interface, isIPv6Enabled: isIPv6)
            #expect(server.interface == interface)
            try server.start()
            defer { server.stop() }
            
            // set up client
            let client = OSCUDPClient(localPort: nil, interface: interface, isIPv6Enabled: isIPv6)
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
