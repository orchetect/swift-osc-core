//
//  TCPSLIPCoding.swift
//  SwiftOSC Core • https://github.com/orchetect/swift-osc-core
//  © 2026 Steffan Andrews • Licensed under MIT License
//

#if canImport(FoundationEssentials)
import struct FoundationEssentials.Data
import protocol FoundationEssentials.DataProtocol
import protocol FoundationEssentials.MutableDataProtocol
#else
import struct Foundation.Data
import protocol Foundation.DataProtocol
import protocol Foundation.MutableDataProtocol
#endif

/// SLIP protocol (RFC 1055) coding utilities.
public enum TCPSLIPCoding { }

// MARK: - Byte

extension TCPSLIPCoding {
    /// SLIP protocol (RFC 1055) byte codes.
    ///
    /// See https://www.rfc-editor.org/rfc/rfc1055.txt
    public enum Byte: UInt8, Sendable {
        /// END (Packet end byte)
        case end = 0xC0

        /// ESC (Packet escape byte)
        case esc = 0xDB

        /// ESC_END (Escaped 'end' byte)
        case escEnd = 0xDC

        /// ESC_ESC (Escaped 'escape' byte)
        case escEsc = 0xDD
    }
}

// MARK: - Encode

extension TCPSLIPCoding {
    /// Returns data encoded as a SLIP packet.
    public static func encode<D: MutableDataProtocol>(_ data: D) -> D {
        data.slipEncoded()
    }
}

extension MutableDataProtocol {
    /// Returns the data encoded as a SLIP packet.
    fileprivate func slipEncoded() -> Self {
        var output = Self()

        // estimate encoded size to be 10% larger than raw data size
        output.reserveCapacity(count + (count / 10))

        output.append(TCPSLIPCoding.Byte.end.rawValue)

        for byte in self {
            switch byte {
            case TCPSLIPCoding.Byte.end.rawValue:
                output.append(TCPSLIPCoding.Byte.esc.rawValue)
                output.append(TCPSLIPCoding.Byte.escEnd.rawValue)
            case TCPSLIPCoding.Byte.esc.rawValue:
                output.append(TCPSLIPCoding.Byte.esc.rawValue)
                output.append(TCPSLIPCoding.Byte.escEsc.rawValue)
            default:
                output.append(byte)
            }
        }

        output.append(TCPSLIPCoding.Byte.end.rawValue)

        return output
    }
}

extension TCPSLIPCoding {
    /// Returns an array of SLIP-encoded packets stripped of their SLIP encoding.
    ///
    /// This can accommodate one or more packets in the same data stream. Each packet is
    /// returned as an element in the array.
    public static func decode(_ data: some DataProtocol) throws(TCPSLIPDecodingError) -> [Data] {
        try data.slipDecoded()
    }
}

// MARK: - Decode

extension DataProtocol {
    /// Returns an array of SLIP-encoded packets stripped of their SLIP encoding.
    ///
    /// This can accommodate one or more packets in the same data stream. Each packet is
    /// returned as an element in the array.
    fileprivate func slipDecoded() throws(TCPSLIPDecodingError) -> [Data] {
        var packets: [Data] = []

        var currentPacketData = Data()
        var isEscaped = false

        for index in indices {
            switch self[index] {
            case TCPSLIPCoding.Byte.end.rawValue:
                // END should never come after an escape byte
                guard !isEscaped else {
                    throw .missingEscapedCharacter
                }

                // consider the END byte the end of the current packet
                if !currentPacketData.isEmpty {
                    packets.append(currentPacketData)
                    currentPacketData = Data()
                }

                // discard one or more sequential END bytes before, between, and after each packet

            case TCPSLIPCoding.Byte.esc.rawValue:
                // we should never get more than one consecutive ESC byte
                guard !isEscaped else {
                    throw .doubleEscapeBytes
                }

                isEscaped = true

            case TCPSLIPCoding.Byte.escEnd.rawValue:
                // if following an ESC byte, translate it
                if isEscaped {
                    isEscaped = false // reset ESC
                    currentPacketData.append(TCPSLIPCoding.Byte.end.rawValue)
                } else {
                    currentPacketData.append(TCPSLIPCoding.Byte.escEnd.rawValue)
                }

            case TCPSLIPCoding.Byte.escEsc.rawValue:
                // if following an ESC byte, translate it
                if isEscaped {
                    isEscaped = false // reset ESC
                    currentPacketData.append(TCPSLIPCoding.Byte.esc.rawValue)
                } else {
                    currentPacketData.append(TCPSLIPCoding.Byte.escEsc.rawValue)
                }

            default:
                // the only two bytes that should follow an ESC byte are ESC_END and ESC_ESC
                guard !isEscaped else {
                    throw .missingEscapedCharacter
                }

                currentPacketData.append(self[index])
            }
        }

        // failsafe: ensure we are not ending while escaped (check if final byte was ESC)
        guard !isEscaped else {
            throw .missingEscapedCharacter
        }

        // add final packet if needed
        if !currentPacketData.isEmpty {
            packets.append(currentPacketData)
        }

        return packets
    }
}
