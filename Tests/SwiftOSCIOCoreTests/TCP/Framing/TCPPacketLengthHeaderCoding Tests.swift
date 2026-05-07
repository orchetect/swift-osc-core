//
//  TCPPacketLengthHeaderCoding Tests.swift
//  SwiftOSC Core • https://github.com/orchetect/swift-osc-core
//  © 2026 Steffan Andrews • Licensed under MIT License
//

#if canImport(FoundationEssentials)
import struct FoundationEssentials.Data
#else
import struct Foundation.Data
#endif

@testable import SwiftOSCIOCore
import Testing

@Suite
struct TCPPacketLengthHeaderCodingTests {
    // swiftformat:disable consecutiveSpaces
    // swiftformat:options --wrap-collections preserve --allow-partial-wrapping true

    /// Test `TCPPacketLengthHeaderCoding.encode()` method.
    @Test
    func encode() {
        #expect(
            TCPPacketLengthHeaderCoding.encode(Data(), byteOrder: .littleEndian)
                == Data([0x00, 0x00, 0x00, 0x00])
        )
        #expect(
            TCPPacketLengthHeaderCoding.encode(Data([0x40]), byteOrder: .littleEndian)
                == Data([0x01, 0x00, 0x00, 0x00, 0x40])
        )
        #expect(
            TCPPacketLengthHeaderCoding.encode(Data([0x40, 0x41]), byteOrder: .littleEndian)
                == Data([0x02, 0x00, 0x00, 0x00, 0x40, 0x41])
        )

        #expect(
            TCPPacketLengthHeaderCoding.encode(Data(), byteOrder: .bigEndian)
                == Data([0x00, 0x00, 0x00, 0x00])
        )
        #expect(
            TCPPacketLengthHeaderCoding.encode(Data([0x40]), byteOrder: .bigEndian)
                == Data([0x00, 0x00, 0x00, 0x01, 0x40])
        )
        #expect(
            TCPPacketLengthHeaderCoding.encode(Data([0x40, 0x41]), byteOrder: .bigEndian)
                == Data([0x00, 0x00, 0x00, 0x02, 0x40, 0x41])
        )
    }

    /// Test `TCPPacketLengthHeaderCoding.decode()` method containing one or fewer packets.
    @Test
    func decode_SinglePacket() throws {
        #expect(
            try TCPPacketLengthHeaderCoding.decode(Data([0x00, 0x00, 0x00, 0x00]), byteOrder: .littleEndian)
                == [Data()]
        )
        #expect(
            try TCPPacketLengthHeaderCoding.decode(Data([0x01, 0x00, 0x00, 0x00, 0x40]), byteOrder: .littleEndian)
                == [Data([0x40])]
        )
        #expect(
            try TCPPacketLengthHeaderCoding.decode(Data([0x02, 0x00, 0x00, 0x00, 0x40, 0x41]), byteOrder: .littleEndian)
                == [Data([0x40, 0x41])]
        )
    }

    /// Test `TCPPacketLengthHeaderCoding.decode()` method containing one or fewer packets -- edge cases.
    @Test
    func decode_SinglePacket_EdgeCases() throws {
        // not enough bytes
        #expect(throws: TCPPacketLengthHeaderDecodingError.notEnoughBytes) {
            try TCPPacketLengthHeaderCoding.decode(Data([0x01, 0x00, 0x00, 0x00]), byteOrder: .littleEndian)
        }

        // too many bytes
        #expect(throws: TCPPacketLengthHeaderDecodingError.notEnoughBytes) {
            try TCPPacketLengthHeaderCoding.decode(Data([0x01, 0x00, 0x00, 0x00, 0x40, 0x41]), byteOrder: .littleEndian)
        }

        // wrong UInt32 size encoding byteOrder
        #expect(throws: TCPPacketLengthHeaderDecodingError.notEnoughBytes) {
            try TCPPacketLengthHeaderCoding.decode(Data([0x00, 0x00, 0x00, 0x01, 0x40]), byteOrder: .littleEndian)
        }
    }

    /// Test `TCPPacketLengthHeaderCoding.decode()` method containing two or more packets.
    @Test
    func decode_MultiplePackets() throws {
        #expect(
            try TCPPacketLengthHeaderCoding.decode(
                Data([0x00, 0x00, 0x00, 0x00,
                      0x00, 0x00, 0x00, 0x00]),
                byteOrder: .littleEndian
            )
                == [Data(), Data()]
        )
        #expect(
            try TCPPacketLengthHeaderCoding.decode(
            Data([0x00, 0x00, 0x00, 0x00,
                      0x01, 0x00, 0x00, 0x00, 0x40]),
                byteOrder: .littleEndian)
                == [Data(), Data([0x40])]
        )
        #expect(
            try TCPPacketLengthHeaderCoding.decode(
                Data([0x01, 0x00, 0x00, 0x00, 0x40,
                      0x01, 0x00, 0x00, 0x00, 0x41]),
                byteOrder: .littleEndian)
                == [Data([0x40]), Data([0x41])]
        )
        #expect(
            try TCPPacketLengthHeaderCoding.decode(
                Data([0x02, 0x00, 0x00, 0x00, 0x40,
                      0x41, 0x01, 0x00, 0x00, 0x00, 0x42]),
                byteOrder: .littleEndian)
                == [Data([0x40, 0x41]), Data([0x42])]
        )
        #expect(
            try TCPPacketLengthHeaderCoding.decode(
                Data([0x02, 0x00, 0x00, 0x00, 0x40, 0x41,
                      0x02, 0x00, 0x00, 0x00, 0x42, 0x43]),
                byteOrder: .littleEndian)
                == [Data([0x40, 0x41]), Data([0x42, 0x43])]
        )
        #expect(
            try TCPPacketLengthHeaderCoding.decode(
                Data([0x02, 0x00, 0x00, 0x00, 0x40, 0x41,
                      0x02, 0x00, 0x00, 0x00, 0x42, 0x43,
                      0x00, 0x00, 0x00, 0x00]),
                byteOrder: .littleEndian)
                == [Data([0x40, 0x41]), Data([0x42, 0x43]), Data()]
        )
        #expect(
            try TCPPacketLengthHeaderCoding.decode(
                Data([0x02, 0x00, 0x00, 0x00, 0x40, 0x41,
                      0x00, 0x00, 0x00, 0x00,
                      0x02, 0x00, 0x00, 0x00, 0x42, 0x43]),
                byteOrder: .littleEndian)
                == [Data([0x40, 0x41]), Data(), Data([0x42, 0x43])]
        )
    }

    /// Test `TCPPacketLengthHeaderCoding.decode()` method containing two or more packets -- edge cases.
    @Test
    func decode_MultiplePackets_EdgeCases() throws {
        // one valid packet and one packet with not enough bytes
        #expect(throws: TCPPacketLengthHeaderDecodingError.notEnoughBytes) {
            try TCPPacketLengthHeaderCoding.decode(
                Data([0x01, 0x00, 0x00, 0x00, 0x40,
                      0x02, 0x00, 0x00, 0x00, 0x41]),
                byteOrder: .littleEndian)
        }

        // one valid packet and one packet with not enough bytes
        #expect(throws: TCPPacketLengthHeaderDecodingError.notEnoughBytes) {
            try TCPPacketLengthHeaderCoding.decode(
                Data([0x01, 0x00, 0x00, 0x00, 0x40,
                      0x01, 0x00, 0x00, 0x00, 0x41, 0x42]),
                byteOrder: .littleEndian)
        }

        // two valid packets and one packet with not enough bytes
        #expect(throws: TCPPacketLengthHeaderDecodingError.notEnoughBytes) {
            try TCPPacketLengthHeaderCoding.decode(
                Data([0x01, 0x00, 0x00, 0x00, 0x40,
                      0x02, 0x00, 0x00, 0x00, 0x41, 0x42,
                      0x02, 0x00, 0x00, 0x00, 0x43]),
                byteOrder: .littleEndian)
        }

        // two packets with wrong UInt32 size encoding byteOrder
        #expect(throws: TCPPacketLengthHeaderDecodingError.notEnoughBytes) {
            try TCPPacketLengthHeaderCoding.decode(
                Data([0x00, 0x00, 0x00, 0x01, 0x40,
                      0x00, 0x00, 0x00, 0x02, 0x41, 0x42]),
                byteOrder: .littleEndian)
        }
    }

    /// Practical test: Encode and decode an OSC Message
    @Test
    func oscEncodeDecode() throws {
        let oscMessage = OSCMessage("/address/here", values: [123, true, 1.5, "abcdefg123456"])
        let oscRawData = try oscMessage.rawData()
        #expect(oscRawData.count == 52)

        let encodedData = TCPPacketLengthHeaderCoding.encode(oscRawData, byteOrder: .bigEndian)
        #expect(encodedData.count == oscRawData.count + 4)
        #expect(encodedData == Data([0x00, 0x00, 0x00, 0x34]) + oscRawData)

        let decodedData = try TCPPacketLengthHeaderCoding.decode(encodedData, byteOrder: .bigEndian)
        #expect(decodedData == [oscRawData])
    }
}
