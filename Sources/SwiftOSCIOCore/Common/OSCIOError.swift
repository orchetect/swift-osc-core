//
//  OSCIOError.swift
//  SwiftOSC Core • https://github.com/orchetect/swift-osc-core
//  © 2026 Steffan Andrews • Licensed under MIT License
//

import protocol Foundation.LocalizedError

/// Error cases thrown during the operation of a SwiftOSC network I/O class.
public enum OSCIOError: LocalizedError {
    /// Invalid interface name or address.
    case invalidInterface

    /// The socket has not been started yet.
    case notStarted

    /// The socket has not been connected yet.
    case notConnected

    /// No remote host was specified.
    case noRemoteHost

    /// Client socket with the given client ID is not found (not connected).
    case clientNotFound(clientID: OSCTCPClientSessionID)

    public var errorDescription: String? {
        switch self {
        case .invalidInterface:
            "Invalid interface name or address."
        case .notStarted:
            "The network socket has not been started yet."
        case .notConnected:
            "The network socket has not been connected yet."
        case .noRemoteHost:
            "A remote host was specified."
        case let .clientNotFound(clientID: clientID):
            "Client socket with ID \(clientID) not found (not connected)."
        }
    }
}

extension OSCIOError: Equatable { }

extension OSCIOError: Hashable { }

extension OSCIOError: Sendable { }
