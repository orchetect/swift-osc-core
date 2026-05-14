//
//  OSCIOError.swift
//  SwiftOSC Core • https://github.com/orchetect/swift-osc-core
//  © 2026 Steffan Andrews • Licensed under MIT License
//

import protocol Foundation.LocalizedError

/// Error cases thrown during the operation of a SwiftOSC network I/O class.
public enum OSCIOError: LocalizedError {
    /// Client socket with the given client ID is not found (not connected).
    case clientNotFound(clientID: OSCTCPClientSessionID)

    /// Invalid interface name or address.
    case invalidInterface

    /// No remote host was specified.
    case noRemoteHost

    /// The socket has not been started yet.
    case notStarted

    /// The socket has not been connected yet.
    case notConnected

    public var errorDescription: String? {
        switch self {
        case let .clientNotFound(clientID: clientID):
            "Client socket with ID \(clientID) not found (not connected)."
        case .invalidInterface:
            "Invalid interface name or address."
        case .noRemoteHost:
            "A remote host was specified."
        case .notStarted:
            "The network socket has not been started yet."
        case .notConnected:
            "The network socket has not been connected yet."
        }
    }
}

extension OSCIOError: Equatable { }

extension OSCIOError: Hashable { }

extension OSCIOError: Sendable { }
