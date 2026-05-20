//
//  OSCTCPClient Interface Tests.swift
//  SwiftOSC Core • https://github.com/orchetect/swift-osc-core
//  © 2026 Steffan Andrews • Licensed under MIT License
//

import Foundation
@testable import SwiftOSCIO
import Testing

extension SerializedTests {
    /// These tests cover both IPv4 and IPv6.
    @Suite
    struct OSCTCPClient_Interface_Tests {
        /// Attempt to bind to a network interface, if one is present that can be used.
        @Test(arguments: ["127.0.0.1", "::1"]) // IPv4 and IPv6 local addresses
        func interfaceBinding_interfaceAddress(toLocalIP localIP: String) throws {
            guard let (_, interfaceAddress) = try networkDevice(
                protocols: [localIP.contains(":") ? .inet6 : .inet],
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
            let server = OSCTCPServer(port: nil, interface: interface)
            #expect(server.interface == interface)
            try server.start()
            
            // set up client
            let client = OSCTCPClient(remoteHost: localIP, remotePort: server.localPort, interface: interface)
            #expect(client.interface == interface)
            try client.connect()
            client.close()
        }
        
        /// Attempt to bind to a network interface, if one is present that can be used.
        @Test(arguments: ["127.0.0.1", "::1"]) // IPv4 and IPv6 local addresses
        func interfaceBinding_interfaceName(toInterfaceNameOfLocalIP localIP: String) throws {
            guard let (interfaceName, _) = try networkDevice(
                protocols: [localIP.contains(":") ? .inet6 : .inet],
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
            let server = OSCTCPServer(port: nil, interface: interface)
            #expect(server.interface == interface)
            try server.start()
            
            // set up client
            let client = OSCTCPClient(remoteHost: localIP, remotePort: server.localPort, interface: interface)
            #expect(client.interface == interface)
            if localIP == "::1" {
                withKnownIssue("When requesting an interface by its name, we can't infer the IP protocol to bind to, so we defer to IPv4") {
                    try client.connect()
                }
            } else {
                try client.connect()
            }
            
            client.close()
        }
        
        /// Attempt to bind to an invalid network interface.
        @Test
        func interfaceBinding_invalid() throws {
            let interface = "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
            
            let client = OSCTCPClient(remoteHost: "127.0.0.1", remotePort: 63076, interface: interface)
            
            #expect(throws: OSCIOError.invalidInterface) {
                try client.connect()
            }
        }
    }
}
