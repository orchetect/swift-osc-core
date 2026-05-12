//
//  OSCUDPSocket Interface Tests.swift
//  SwiftOSC Core • https://github.com/orchetect/swift-osc-core
//  © 2026 Steffan Andrews • Licensed under MIT License
//

#if canImport(Darwin) && !os(watchOS)

import Foundation
@testable import SwiftOSCIO
import Testing

@Suite(.serialized)
struct OSCUDPSocket_Interface_Tests {
    /// Attempt to bind to a network interface, if one is present that can be used.
    @MainActor @Test
    func interfaceBinding_interfaceAddress() async throws {
        let interfaces = try ipV4NetworkDevices(includeLoopback: false)
        
        print("Found interfaces:")
        dump(interfaces)
        
        guard let (_, interfaceAddress) = interfaces.first else {
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
    @MainActor @Test
    func interfaceBinding_interfaceName() async throws {
        let interfaces = try ipV4NetworkDevices(includeLoopback: false)
        
        print("Found interfaces:")
        dump(interfaces)
        
        guard let (interfaceName, _) = interfaces.first else {
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
    @MainActor @Test
    func interfaceBinding_invalid() async throws {
        let interface = "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
        
        let socket = OSCUDPSocket(interface: interface)
        
        #expect(throws: OSCTCPClientError.invalidInterface) {
            try socket.start()
        }
    }
}

#endif
