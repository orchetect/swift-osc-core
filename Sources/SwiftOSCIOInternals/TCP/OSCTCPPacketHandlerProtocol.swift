//
//  OSCTCPPacketHandlerProtocol.swift
//  SwiftOSC Core • https://github.com/orchetect/swift-osc-core
//  © 2026 Steffan Andrews • Licensed under MIT License
//

import Foundation
import SwiftDataParsing

/// Protocol that TCP-based OSC I/O classes adopt in order to handle incoming OSC packets.
public protocol OSCTCPPacketHandlerProtocol: OSCPacketDispatcherProtocol {
    /// TCP framing mode used by the connection.
    var framingMode: OSCTCPFramingMode { get }
}

extension OSCTCPPacketHandlerProtocol {
    /// Handle incoming OSC data.
    ///
    /// > Note:
    /// >
    /// > This method is called internally by OSC server and socket classes and is not needed to be called externally.
    public func handle(receivedData data: some DataProtocol, remoteHost: String, remotePort: UInt16) {
        // This routine must accommodate more than one consecutive packet contained in the data
        // which may happen when multiple packets are sent rapidly from a client.

        switch framingMode {
        case .osc1_0:
            do {
                let packets = try TCPPacketLengthHeaderCoding.decode(data, byteOrder: .bigEndian)

                guard !packets.isEmpty else {
                    #if DEBUG
                    print("Failed to parse OSC packets from incoming TCP data.")
                    #endif

                    return
                }

                _handle(receivedPackets: packets, remoteHost: remoteHost, remotePort: remotePort)
            } catch {
                #if DEBUG
                print("OSC 1.0 packet-length header decoding error:", error.localizedDescription)
                #endif

                return
            }

        case .osc1_1:
            do {
                let packets = try TCPSLIPCoding.decode(data)

                guard !packets.isEmpty else {
                    #if DEBUG
                    print("Failed to parse OSC packets from incoming TCP data.")
                    #endif

                    return
                }

                _handle(receivedPackets: packets, remoteHost: remoteHost, remotePort: remotePort)
            } catch {
                #if DEBUG
                print("OSC 1.1 SLIP decoding error:", error.localizedDescription)
                #endif

                return
            }

        case .none:
            // TODO: data may contain more than one OSC packet - need to figure out how to either parse out multiple consecutive OSC bundles/messages from raw data, or somehow intuit packet byte offsets within the data if possible.
            let packets = [data]
            _handle(receivedPackets: packets, remoteHost: remoteHost, remotePort: remotePort)
        }
    }

    func _handle(receivedPackets packets: some Sequence<some DataProtocol>, remoteHost: String, remotePort: UInt16) {
        for packetData in packets {
            do throws(OSCDecodeError) {
                guard let oscPacket = try OSCPacket(from: packetData) else {
                    #if DEBUG
                    print("Error parsing OSC packet from incoming TCP data; it may not be OSC data or may be malformed.")
                    #endif

                    continue
                }
                dispatch(packet: oscPacket, remoteHost: remoteHost, remotePort: remotePort)
            } catch {
                report(error: error, forMalformedData: Data(packetData), remoteHost: remoteHost, remotePort: remotePort)
            }
        }
    }
}
