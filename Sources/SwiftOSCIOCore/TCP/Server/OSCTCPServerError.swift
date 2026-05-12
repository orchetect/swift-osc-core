//
//  OSCTCPServerError.swift
//  SwiftOSC Core • https://github.com/orchetect/swift-osc-core
//  © 2026 Steffan Andrews • Licensed under MIT License
//

import protocol Foundation.LocalizedError

/// Error cases thrown during the operation of OSC TCP sockets.
public enum OSCTCPServerError: LocalizedError {
    /// Invalid interface name or address.
    case invalidInterface
    
    /// The OSC TCP socket has not been started yet.
    case notStarted
    
    /// OSC TCP client socket with the given client ID is not found (not connected).
    case clientNotFound(clientID: OSCTCPClientSessionID)
    
    public var errorDescription: String? {
        switch self {
        case .invalidInterface:
            "Invalid interface name or address."
        case .notStarted:
            "The OSC TCP socket has not been started yet."
        case let .clientNotFound(clientID: clientID):
            "OSC TCP client socket with ID \(clientID) not found (not connected)."
        }
    }
}

extension OSCTCPServerError: Equatable { }

extension OSCTCPServerError: Hashable { }

extension OSCTCPServerError: Sendable { }
