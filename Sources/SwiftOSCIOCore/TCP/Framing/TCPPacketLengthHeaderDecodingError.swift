//
//  TCPPacketLengthHeaderDecodingError.swift
//  SwiftOSC Core • https://github.com/orchetect/swift-osc-core
//  © 2026 Steffan Andrews • Licensed under MIT License
//

import protocol Foundation.LocalizedError

/// Error cases thrown while decoding packet data encoded with packet-length header framing.
public enum TCPPacketLengthHeaderDecodingError: LocalizedError {
    /// Not enough bytes.
    case notEnoughBytes

    public var errorDescription: String? {
        switch self {
        case .notEnoughBytes:
            "Not enough bytes."
        }
    }
}

extension TCPPacketLengthHeaderDecodingError: Equatable { }

extension TCPPacketLengthHeaderDecodingError: Hashable { }

extension TCPPacketLengthHeaderDecodingError: Sendable { }
