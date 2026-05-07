//
//  Packet Length Header Coding.swift
//  SwiftOSC Core • https://github.com/orchetect/swift-osc-core
//  © 2026 Steffan Andrews • Licensed under MIT License
//

#if canImport(FoundationEssentials)
import protocol FoundationEssentials.MutableDataProtocol
#else
import protocol Foundation.MutableDataProtocol
#endif

import SwiftDataParsing

extension MutableDataProtocol {
    /// Returns the data encoded as a packet-length header framed datagram.
    func packetLengthHeaderEncoded(byteOrder: ByteOrder = .platformDefault) -> Self {
        let length = UInt32(count)
            .toData(byteOrder)
        return length + self
    }

    /// Decodes data that may contain one or more packet-length header framed datagrams.
    ///
    /// The structure is one or more of: a UInt32 length value followed by a sequence of bytes of that length.
    func packetLengthHeaderDecoded(
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
