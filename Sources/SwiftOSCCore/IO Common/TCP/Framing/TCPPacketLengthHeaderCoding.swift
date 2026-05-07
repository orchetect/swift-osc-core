//
//  TCPPacketLengthHeaderCoding.swift
//  SwiftOSC Core • https://github.com/orchetect/swift-osc-core
//  © 2026 Steffan Andrews • Licensed under MIT License
//

#if canImport(FoundationEssentials)
import protocol FoundationEssentials.DataProtocol
import protocol FoundationEssentials.MutableDataProtocol
#else
import protocol Foundation.DataProtocol
import protocol Foundation.MutableDataProtocol
#endif

import SwiftDataParsing

/// TCP packet length header coding utilities.
public enum TCPPacketLengthHeaderCoding { }

// MARK: - Encode

extension TCPPacketLengthHeaderCoding {
    /// Returns the data encoded as a packet-length header framed datagram.
    public static func encode<D: MutableDataProtocol>(_ data: D, byteOrder: ByteOrder = .platformDefault) -> D {
        data.packetLengthHeaderEncoded(byteOrder: byteOrder)
    }
}

extension MutableDataProtocol {
    /// Returns the data encoded as a packet-length header framed datagram.
    fileprivate func packetLengthHeaderEncoded(byteOrder: ByteOrder = .platformDefault) -> Self {
        let length = UInt32(count)
            .toData(byteOrder)
        return length + self
    }
}

// MARK: - Decode

extension TCPPacketLengthHeaderCoding {
    /// Decodes data that may contain one or more packet-length header framed datagrams.
    ///
    /// The structure is one or more of: a `UInt32` length value followed by a sequence of bytes of that length.
    public static func decode<D: DataProtocol>(
        _ data: D,
        byteOrder: ByteOrder = .platformDefault
    ) throws(OSCTCPPacketLengthHeaderDecodingError) -> [D.SubSequence] {
        try data.packetLengthHeaderDecoded(byteOrder: byteOrder)
    }
}

extension DataProtocol {
    /// Decodes data that may contain one or more packet-length header framed datagrams.
    ///
    /// The structure is one or more of: a `UInt32` length value followed by a sequence of bytes of that length.
    fileprivate func packetLengthHeaderDecoded(
        byteOrder: ByteOrder = .platformDefault
    ) throws(OSCTCPPacketLengthHeaderDecodingError) -> [SubSequence] {
        var sequences: [SubSequence] = []

        var offset: Index = startIndex

        while offset < endIndex {
            guard distance(from: offset, to: endIndex) >= 4 else {
                throw .notEnoughBytes
            }
            let lengthFieldRange = offset ..< index(offset, offsetBy: 4)

            guard let length = self[lengthFieldRange]
                .toUInt32(from: byteOrder)
            else {
                throw .notEnoughBytes
            }
            
            offset = lengthFieldRange.upperBound

            guard distance(from: offset, to: endIndex) >= Int(length) else {
                throw .notEnoughBytes
            }
            let packetRange = offset ..< index(offset, offsetBy: Int(length))

            offset = packetRange.upperBound

            let sequence: SubSequence = self[packetRange]
            sequences.append(sequence)
        }

        return sequences
    }
}
