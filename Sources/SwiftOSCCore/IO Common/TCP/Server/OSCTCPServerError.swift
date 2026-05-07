//
//  OSCTCPServerError.swift
//  SwiftOSC Core • https://github.com/orchetect/swift-osc-core
//  © 2026 Steffan Andrews • Licensed under MIT License
//

import protocol Foundation.LocalizedError

/// Error cases thrown during the operation of OSC TCP sockets.
public enum OSCTCPServerError: LocalizedError {
    case notStarted
    case clientNotFound(OSCTCPClientSessionID)
    
    public var errorDescription: String? {
        switch self {
        case .notStarted:
            "The OSC TCP socket has not been started yet."
        case let .clientNotFound(id):
            "OSC TCP client socket with ID \(id) not found (not connected)."
        }
    }
}

extension OSCTCPServerError: Equatable { }

extension OSCTCPServerError: Hashable { }

extension OSCTCPServerError: Sendable { }
