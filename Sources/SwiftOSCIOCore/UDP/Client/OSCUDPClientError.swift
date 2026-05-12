//
//  OSCUDPClientError.swift
//  SwiftOSC Core • https://github.com/orchetect/swift-osc-core
//  © 2026 Steffan Andrews • Licensed under MIT License
//

import protocol Foundation.LocalizedError

/// Error cases thrown during the operation of an OSC UDP client.
public enum OSCUDPClientError: LocalizedError {
    /// Invalid interface name or address.
    case invalidInterface
    
    /// The OSC UDP client has not been started yet.
    case notStarted
    
    /// A remote host was not specified.
    case noRemoteHost
    
    public var errorDescription: String? {
        switch self {
        case .invalidInterface:
            "Invalid interface name or address."
        case .notStarted:
            "The OSC UDP client has not been started yet."
        case .noRemoteHost:
            "A remote host was not specified."
        }
    }
}

extension OSCUDPClientError: Equatable { }

extension OSCUDPClientError: Hashable { }

extension OSCUDPClientError: Sendable { }
