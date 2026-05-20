//
//  OSCUDPSocket Interface Tests.swift
//  SwiftOSC Core • https://github.com/orchetect/swift-osc-core
//  © 2026 Steffan Andrews • Licensed under MIT License
//

import Foundation
import NIOCore
@testable import SwiftOSCIO
import Testing

extension SerializedTests {
    /// These tests cover both IPv4 and IPv6.
    @Suite
    struct OSCUDPSocket_Interface_Tests {
        /// Attempt to bind to a network interface, if one is present that can be used.
        @Test(arguments: [.inet, .inet6] as [NIOBSDSocket.ProtocolFamily]) // IPv4 and IPv6
        func interfaceBinding_interfaceAddress(proto: NIOBSDSocket.ProtocolFamily) throws {
            let interfaces = try networkDevices(protocols: [proto], includeLoopback: false)
            
            print("Found \(proto) interfaces:")
            dump(interfaces)
            
            let enInterfaces = interfaces.filter {
                $0.name.hasPrefix("en")
                && !$0.address.lowercased().hasPrefix("169.") // ignore default IPv4 gateway
                && !$0.address.lowercased().hasPrefix("fe80:") // ignore default IPv6 gateway
            }
            
            guard let (_, interfaceAddress) = enInterfaces.first else {
                withKnownIssue {
                    Issue.record("No available network interfaces to test. Skipping test.")
                }
                return
            }
            
            let interface = interfaceAddress
            print("Using interface \"\(interface)\"")
            
            // set up server
            let socket = OSCUDPSocket(interface: interface)
            #expect(socket.interface == interface)
            try socket.start()
            socket.stop()
        }
        
        /// Attempt to bind to a network interface, if one is present that can be used.
        @Test(arguments: [.inet, .inet6] as [NIOBSDSocket.ProtocolFamily]) // IPv4 and IPv6
        func interfaceBinding_interfaceName(proto: NIOBSDSocket.ProtocolFamily) throws {
            let interfaces = try networkDevices(protocols: [proto], includeLoopback: false)
            
            print("Found \(proto) interfaces:")
            dump(interfaces)
            
            let enInterfaces = interfaces.filter { $0.name.hasPrefix("en") }
            
            guard let (interfaceName, _) = enInterfaces.first else {
                withKnownIssue {
                    Issue.record("No available network interfaces to test. Skipping test.")
                }
                return
            }
            
            let interface = interfaceName
            print("Using interface \"\(interface)\"")
            
            // set up server
            let socket = OSCUDPSocket(interface: interface)
            #expect(socket.interface == interface)
            try socket.start()
            socket.stop()
        }
        
        /// Attempt to bind to an invalid network interface.
        @Test
        func interfaceBinding_invalid() throws {
            let interface = "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
            
            let socket = OSCUDPSocket(interface: interface)
            
            #expect(throws: OSCIOError.invalidInterface) {
                try socket.start()
            }
        }
    }
}
