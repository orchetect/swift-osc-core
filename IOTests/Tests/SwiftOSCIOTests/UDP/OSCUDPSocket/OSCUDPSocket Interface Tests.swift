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
    @Suite
    struct OSCUDPSocket_Interface_Tests {
        /// Attempt to bind to an IPv4 network interface, if one is present that can be used.
        @Test
        func interfaceBinding_interfaceAddress() throws {
            let interfaces = try networkDevices(protocols: [.inet], includeLoopback: false)
            
            print("IPv4 interfaces found:")
            dump(interfaces)
            
            let filteredInterfaces = interfaces.filter {
                !$0.address.lowercased().hasPrefix("169.") // ignore default IPv4 gateway
            }
            
            guard !filteredInterfaces.isEmpty else {
                withKnownIssue {
                    Issue.record("No available network interfaces to test. Skipping test.")
                }
                return
            }
            
            // test de-flaking: try all possible addresses checking for at least one that succeeds
            var successCount = 0
            for (_, interfaceAddress) in filteredInterfaces {
                let interface = interfaceAddress
                print("Trying interface with address \"\(interface)\"")
                
                // set up server
                let socket = OSCUDPSocket(interface: interface)
                #expect(socket.interface == interface)
                
                do {
                    try socket.start()
                    print("Interface \(interface) succeeded")
                    successCount += 1
                } catch {
                    print("Interface \(interface) failed")
                }
                socket.stop()
            }
            
            #expect(successCount > 0)
        }
        
        /// Attempt to bind to an IPv4 network interface, if one is present that can be used.
        @Test
        func interfaceBinding_interfaceName() throws {
            let interfaces = try networkDevices(protocols: [.inet], includeLoopback: false)
            
            print("IPv4 interfaces found:")
            dump(interfaces)
            
            let filteredInterfaces = interfaces.filter {
                $0.name.hasPrefix("en")
            }
            
            guard !filteredInterfaces.isEmpty else {
                withKnownIssue {
                    Issue.record("No available network interfaces to test. Skipping test.")
                }
                return
            }
            
            // test de-flaking: try all possible addresses checking for at least one that succeeds
            var successCount = 0
            for (interfaceName, _) in filteredInterfaces {
                let interface = interfaceName
                print("Trying interface named \"\(interface)\"")
                
                // set up server
                let socket = OSCUDPSocket(interface: interface)
                #expect(socket.interface == interface)
                
                do {
                    try socket.start()
                    print("Interface \(interface) succeeded")
                    successCount += 1
                } catch {
                    print("Interface \(interface) failed")
                }
                socket.stop()
            }
            
            #expect(successCount > 0)
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
