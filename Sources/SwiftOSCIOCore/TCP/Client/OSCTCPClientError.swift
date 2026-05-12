//
//  OSCTCPClientError.swift
//  SwiftOSC Core • https://github.com/orchetect/swift-osc-core
//  © 2026 Steffan Andrews • Licensed under MIT License
//

import protocol Foundation.LocalizedError

/// Error cases thrown during the operation of an OSC TCP client.
public enum OSCTCPClientError: LocalizedError {
    /// The OSC TCP socket has not been started yet.
    case notStarted
    
    /// A remote host was specified at initialization or in call to `send()`.
    case noRemoteHost
    
    public var errorDescription: String? {
        switch self {
        case .notStarted:
            "The OSC TCP socket has not been started yet."
        case .noRemoteHost:
            "A remote host was specified at initialization or in call to send()."
        }
    }
}

extension OSCTCPClientError: Equatable { }

extension OSCTCPClientError: Hashable { }

extension OSCTCPClientError: Sendable { }
