//
//  OSCTCPServer Interface Tests.swift
//  SwiftOSC Core • https://github.com/orchetect/swift-osc-core
//  © 2026 Steffan Andrews • Licensed under MIT License
//

import Foundation
import NIOCore
@testable import SwiftOSCIO
import Testing

extension SerializedTests {
    @Suite
    struct OSCTCPServer_Interface_Tests {
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
                let server = OSCTCPServer(port: nil, interface: interface)
                #expect(server.interface == interface)

                do {
                    try server.start()
                    print("Interface \(interface) succeeded")
                    successCount += 1
                } catch {
                    print("Interface \(interface) failed")
                }
                server.stop()
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
                let server = OSCTCPServer(port: nil, interface: interface)
                #expect(server.interface == interface)

                do {
                    try server.start()
                    print("Interface \(interface) succeeded")
                    successCount += 1
                } catch {
                    print("Interface \(interface) failed")
                }
                server.stop()
            }

            #expect(successCount > 0)
        }

        /// Attempt to bind to a wildcard address via the `interface` parameter.
        @Test(arguments: [("0.0.0.0", "127.0.0.1", false), ("::", "::1", true)]) // IPv4 and IPv6
        func interfaceBinding_wildcardAddress(wildcardAddress: String, localIP: String, isIPv6: Bool) throws {
            let interface = wildcardAddress
            print("Using interface \"\(interface)\"")

            let server = OSCTCPServer(port: nil, interface: interface, isIPv6Enabled: isIPv6)
            #expect(server.interface == interface)
            try server.start()
            server.stop()
        }

        /// Attempt to bind to an invalid network interface.
        @Test
        func interfaceBinding_invalid() throws {
            let interface = "ABCDEFGHIJKLMNOPQRSTUVWXYZ"

            let server = OSCTCPServer(port: nil, interface: interface)

            #expect(throws: OSCIOError.invalidInterface) {
                try server.start()
            }
        }
    }
}
