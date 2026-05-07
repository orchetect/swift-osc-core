//
//  TCPSLIPCoding Tests.swift
//  SwiftOSC Core • https://github.com/orchetect/swift-osc-core
//  © 2026 Steffan Andrews • Licensed under MIT License
//

#if canImport(FoundationEssentials)
import struct FoundationEssentials.Data
#else
import struct Foundation.Data
#endif

@testable import SwiftOSCCore
import Testing

@Suite
struct TCPSLIPCodingTests {
    private let END: UInt8 = 0xC0
    private let ESC: UInt8 = 0xDB
    private let ESC_END: UInt8 = 0xDC
    private let ESC_ESC: UInt8 = 0xDD

    /// Test `TCPSLIPCoding.encode()` method.
    @Test
    func encode() {
        #expect(TCPSLIPCoding.encode(Data()) == Data([END, END]))
        #expect(TCPSLIPCoding.encode(Data([0x01])) == Data([END, 0x01, END]))
        #expect(TCPSLIPCoding.encode(Data([0x01, 0x02])) == Data([END, 0x01, 0x02, END]))

        // just establishing that it is possible to recursively encode, even though we'd never want to.
        // perhaps in future this could check to see if the data is already encoded to prevent this.
        #expect(
            Data(TCPSLIPCoding.encode(TCPSLIPCoding.encode([0x01, 0x02])))
                == Data([END, ESC, ESC_END, 0x01, 0x02, ESC, ESC_END, END])
        )

        #expect(TCPSLIPCoding.encode(Data([0x01, END, 0x02])) == Data([END, 0x01, ESC, ESC_END, 0x02, END]))
        #expect(TCPSLIPCoding.encode(Data([0x01, ESC, 0x02])) == Data([END, 0x01, ESC, ESC_ESC, 0x02, END]))

        #expect(TCPSLIPCoding.encode(Data([0x01, END, END, 0x02])) == Data([END, 0x01, ESC, ESC_END, ESC, ESC_END, 0x02, END]))
        #expect(TCPSLIPCoding.encode(Data([0x01, ESC, ESC, 0x02])) == Data([END, 0x01, ESC, ESC_ESC, ESC, ESC_ESC, 0x02, END]))
        #expect(TCPSLIPCoding.encode(Data([0x01, ESC, END, 0x02])) == Data([END, 0x01, ESC, ESC_ESC, ESC, ESC_END, 0x02, END]))
        #expect(TCPSLIPCoding.encode(Data([0x01, END, ESC, 0x02])) == Data([END, 0x01, ESC, ESC_END, ESC, ESC_ESC, 0x02, END]))

        #expect(
            TCPSLIPCoding.encode(Data([0x01, 0x02, ESC, 0x03, END, 0x04]))
                == Data([END, 0x01, 0x02, ESC, ESC_ESC, 0x03, ESC, ESC_END, 0x04, END])
        )
    }

    /// Test `TCPSLIPCoding.decode()` method containing one or fewer packets.
    @Test
    func decode_SinglePacket() throws {
        // without double END bytes
        #expect(try TCPSLIPCoding.decode(Data()) == [])
        #expect(try TCPSLIPCoding.decode(Data([0x01])) == [Data([0x01])])
        #expect(try TCPSLIPCoding.decode(Data([0x01, 0x02])) == [Data([0x01, 0x02])])
        #expect(try TCPSLIPCoding.decode(Data([0x01, 0x02, 0x03])) == [Data([0x01, 0x02, 0x03])])

        // with double END bytes
        #expect(try TCPSLIPCoding.decode(Data([END, END])) == [])
        #expect(try TCPSLIPCoding.decode(Data([END, 0x01, END])) == [Data([0x01])])
        #expect(try TCPSLIPCoding.decode(Data([END, 0x01, 0x02, END])) == [Data([0x01, 0x02])])
        #expect(try TCPSLIPCoding.decode(Data([END, 0x01, 0x02, 0x03, END])) == [Data([0x01, 0x02, 0x03])])

        // without double END bytes
        #expect(try TCPSLIPCoding.decode(Data([ESC, ESC_END])) == [Data([END])])
        #expect(try TCPSLIPCoding.decode(Data([ESC, ESC_ESC])) == [Data([ESC])])
        #expect(try TCPSLIPCoding.decode(Data([ESC, ESC_END, ESC, ESC_END])) == [Data([END, END])])
        #expect(try TCPSLIPCoding.decode(Data([ESC, ESC_ESC, ESC, ESC_ESC])) == [Data([ESC, ESC])])
        #expect(try TCPSLIPCoding.decode(Data([ESC, ESC_ESC, ESC, ESC_END])) == [Data([ESC, END])])
        #expect(try TCPSLIPCoding.decode(Data([ESC, ESC_END, ESC, ESC_ESC])) == [Data([END, ESC])])

        // with double END bytes
        #expect(try TCPSLIPCoding.decode(Data([END, ESC, ESC_END, END])) == [Data([END])])
        #expect(try TCPSLIPCoding.decode(Data([END, ESC, ESC_ESC, END])) == [Data([ESC])])
        #expect(try TCPSLIPCoding.decode(Data([END, ESC, ESC_END, ESC, ESC_END, END])) == [Data([END, END])])
        #expect(try TCPSLIPCoding.decode(Data([END, ESC, ESC_ESC, ESC, ESC_ESC, END])) == [Data([ESC, ESC])])
        #expect(try TCPSLIPCoding.decode(Data([END, ESC, ESC_ESC, ESC, ESC_END, END])) == [Data([ESC, END])])
        #expect(try TCPSLIPCoding.decode(Data([END, ESC, ESC_END, ESC, ESC_ESC, END])) == [Data([END, ESC])])

        #expect(
            try TCPSLIPCoding.decode(Data([END, 0x01, ESC, ESC_ESC, 0x02, ESC, ESC_END, 0x03, END]))
                == [Data([0x01, ESC, 0x02, END, 0x03])]
        )

        // more than one END byte at start
        #expect(try TCPSLIPCoding.decode(Data([END, END, 0x01])) == [Data([0x01])])
        #expect(try TCPSLIPCoding.decode(Data([END, END, END, 0x01])) == [Data([0x01])])
        #expect(try TCPSLIPCoding.decode(Data([END, END, 0x01, END])) == [Data([0x01])])
        #expect(try TCPSLIPCoding.decode(Data([END, END, END, 0x01, END])) == [Data([0x01])])

        // more than one END byte at end
        #expect(try TCPSLIPCoding.decode(Data([0x01, END, END])) == [Data([0x01])])
        #expect(try TCPSLIPCoding.decode(Data([END, 0x01, END, END])) == [Data([0x01])])
        #expect(try TCPSLIPCoding.decode(Data([0x01, END, END, END])) == [Data([0x01])])
        #expect(try TCPSLIPCoding.decode(Data([END, 0x01, END, END, END])) == [Data([0x01])])
    }

    /// Test `TCPSLIPCoding.decode()` method containing two or more packets.
    @Test
    func decode_MultiplePackets() throws {
        #expect(try TCPSLIPCoding.decode(Data([END, END, 0x01, END])) == [Data([0x01])])

        #expect(try TCPSLIPCoding.decode(Data([END, 0x01, END, 0x02, END])) == [Data([0x01]), Data([0x02])])

        #expect(
            try TCPSLIPCoding.decode(Data([END, 0x01, 0x02, END, 0x03, 0x04, END]))
                == [Data([0x01, 0x02]), Data([0x03, 0x04])]
        )

        #expect(
            try TCPSLIPCoding.decode(Data([END, 0x01, END, 0x02, END, 0x03, END]))
                == [Data([0x01]), Data([0x02]), Data([0x03])]
        )
    }

    /// Test for error: two consecutive ESC bytes is not technically valid.
    @Test
    func decode_DoubleEscapeBytes() throws {
        #expect(throws: TCPSLIPDecodingError.doubleEscapeBytes) {
            try TCPSLIPCoding.decode(Data([END, 0x01, ESC, ESC, 0x02, END]))
        }
        #expect(throws: TCPSLIPDecodingError.doubleEscapeBytes) {
            try TCPSLIPCoding.decode(Data([END, 0x01, ESC, ESC, ESC_END, 0x02, END]))
        }
        #expect(throws: TCPSLIPDecodingError.doubleEscapeBytes) {
            try TCPSLIPCoding.decode(Data([END, 0x01, ESC, ESC, ESC_END, ESC_END, 0x02, END]))
        }
    }

    /// Encountering an escaped character without first receiving an ESC byte
    /// should treat the byte as-is.
    @Test
    func decode_MissingEscapeByte() throws {
        #expect(
            try TCPSLIPCoding.decode(Data([END, 0x01, ESC_ESC, 0x02, END]))
                == [Data([0x01, ESC_ESC, 0x02])]
        )
        #expect(
            try TCPSLIPCoding.decode(Data([END, 0x01, ESC_END, 0x02, END]))
                == [Data([0x01, ESC_END, 0x02])]
        )
        #expect(
            try TCPSLIPCoding.decode(Data([END, ESC_ESC, END]))
                == [Data([ESC_ESC])]
        )
        #expect(
            try TCPSLIPCoding.decode(Data([END, ESC_END, END]))
                == [Data([ESC_END])]
        )
    }

    /// Test for error: missing valid escaped character after receiving ESC byte.
    @Test
    func decode_MissingEscapedCharacter() throws {
        #expect(throws: TCPSLIPDecodingError.missingEscapedCharacter) {
            try TCPSLIPCoding.decode(Data([END, 0x01, ESC, 0x02, END]))
        }
        #expect(throws: TCPSLIPDecodingError.missingEscapedCharacter) {
            try TCPSLIPCoding.decode(Data([END, 0x01, ESC, 0x02, ESC_END, END]))
        }
        #expect(throws: TCPSLIPDecodingError.missingEscapedCharacter) {
            try TCPSLIPCoding.decode(Data([END, 0x01, ESC, 0x02, ESC_ESC, END]))
        }
        #expect(throws: TCPSLIPDecodingError.missingEscapedCharacter) {
            try TCPSLIPCoding.decode(Data([END, 0x01, ESC, END]))
        }
    }

    /// Practical test: Encode and decode an OSC Message
    @Test
    func oscEncodeDecode() throws {
        let oscMessage = OSCMessage("/address/here", values: [123, true, 1.5, "abcdefg123456"])
        let oscRawData = try oscMessage.rawData()

        let encodedData = TCPSLIPCoding.encode(oscRawData)
        // we won't bother checking all encoded bytes, but just a baseline check that the data is different
        #expect(oscRawData.count != encodedData.count)

        let decodedData = try TCPSLIPCoding.decode(encodedData)
        #expect(decodedData == [oscRawData])
    }

    /// Test encoding all possible byte values.
    @Test
    func allByteValuesEncodeDecode() throws {
        for value in UInt8(0) ... UInt8(255) {
            let valueByte = Data([value])
            let hex = "0x" + ("00" + String(value, radix: 16, uppercase: true)).suffix(2)
            let byteDescription = "Byte \(hex)"
            let encoded = TCPSLIPCoding.encode(valueByte)
            do {
                let decoded = try TCPSLIPCoding.decode(encoded)
                #expect(decoded == [valueByte], "\(byteDescription)")
            } catch {
                Issue.record("\(byteDescription) error: \(error.localizedDescription)")
            }
        }
    }
}
