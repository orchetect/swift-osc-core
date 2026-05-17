//
//  Test Network Utilities.swift
//  SwiftOSC Core • https://github.com/orchetect/swift-osc-core
//  © 2026 Steffan Andrews • Licensed under MIT License
//

import NIOCore

/// Returns network devices in the system that have an address.
func networkDevices(includeLoopback: Bool) throws -> [(name: String, address: SocketAddress)] {
    try System
        .enumerateDevices()
        .filter { includeLoopback ? true : !$0.name.starts(with: "lo") }
        .compactMap { device -> (name: String, address: SocketAddress)? in
            guard let address = device.address else { return nil }
            return (name: device.name, address: address)
        }
}

func networkDevices(
    protocols: [NIOBSDSocket.ProtocolFamily],
    includeLoopback: Bool
) throws -> [(name: String, address: String)] {
    try networkDevices(includeLoopback: includeLoopback)
        .filter { protocols.contains($0.address.protocol) }
        .compactMap {
            guard let address = $0.address.ipAddress else { return nil }
            return (name: $0.name, address: address)
        }
        .sorted { lhs, rhs in
            lhs.name < rhs.name
        }
}

func networkDevice(
    protocols: [NIOBSDSocket.ProtocolFamily],
    includeLoopback: Bool,
    forAddress: String,
) throws -> (name: String, address: String)? {
    try networkDevices(protocols: protocols, includeLoopback: includeLoopback)
        .filter { $0.address == forAddress }
        .first
}
