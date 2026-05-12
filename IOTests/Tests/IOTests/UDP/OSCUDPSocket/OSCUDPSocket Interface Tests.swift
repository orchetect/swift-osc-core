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
        
        guard let interface = interfaces.first else {
            withKnownIssue {
                Issue.record("No available network interfaces to test. Skipping test.")
            }
            return
        }
        
        print("Using interface \"\(interface.name)\" (\(interface.address))")
        
        // set up server
        let server = OSCUDPSocket(interface: interface.address)
        try server.start()
        server.stop()
    }
    
    /// Attempt to bind to a network interface, if one is present that can be used.
    @MainActor @Test
    func interfaceBinding_interfaceName() async throws {
        let interfaces = try ipV4NetworkDevices(includeLoopback: false)
        
        print("Found interfaces:")
        dump(interfaces)
        
        guard let interface = interfaces.first else {
            withKnownIssue {
                Issue.record("No available network interfaces to test. Skipping test.")
            }
            return
        }
        
        print("Using interface \"\(interface.name)\" (\(interface.address))")
        
        // set up server
        let server = OSCUDPSocket(interface: interface.name)
        try server.start()
        server.stop()
    }

    /// Attempt to bind to an invalid network interface.
    @MainActor @Test
    func interfaceBinding_invalid() async throws {
        let interface = "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
        
        let server = OSCUDPSocket(interface: interface)
        
        #expect(throws: OSCTCPClientError.invalidInterface) {
            try server.start()
        }
    }
}

#endif
