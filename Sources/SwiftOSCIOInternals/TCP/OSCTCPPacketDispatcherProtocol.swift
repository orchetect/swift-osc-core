//
//  OSCTCPPacketDispatcherProtocol.swift
//  SwiftOSC Core • https://github.com/orchetect/swift-osc-core
//  © 2026 Steffan Andrews • Licensed under MIT License
//

import Foundation
import SwiftDataParsing

/// Protocol that TCP-based OSC I/O classes adopt in order to handle incoming OSC packets.
public protocol OSCTCPPacketDispatcherProtocol: OSCPacketDispatcherProtocol {
    /// TCP framing mode used by the connection.
    var framingMode: OSCTCPFramingMode { get }
}

extension OSCTCPPacketDispatcherProtocol {
    /// Handle incoming OSC data.
    ///
    /// > Note:
    /// >
    /// > This method is called internally by OSC server and socket classes and is not needed to be called externally.
    public func dispatch(receivedTCPFramedData data: some DataProtocol, remoteHost: String, remotePort: UInt16) {
        // This routine must accommodate more than one consecutive packet contained in the data
        // which may happen when multiple packets are sent rapidly from a client.

        switch framingMode {
        case .osc1_0:
            do {
                let packets = try TCPPacketLengthHeaderCoding.decode(data, byteOrder: .bigEndian)

                guard !packets.isEmpty else {
                    let errorMessage = "No OSC packets were parsed from incoming TCP data. This is likely the result of malformed data."
                    report(error: .malformed(errorMessage), forMalformedData: Data(data), remoteHost: remoteHost, remotePort: remotePort)
                    return
                }

                dispatch(receivedPackets: packets, remoteHost: remoteHost, remotePort: remotePort)
            } catch {
                let errorMessage = "OSC 1.0 packet-length header decoding error: \(error)"
                report(error: .malformed(errorMessage), forMalformedData: Data(data), remoteHost: remoteHost, remotePort: remotePort)
                return
            }

        case .osc1_1:
            do {
                let packets = try TCPSLIPCoding.decode(data)

                guard !packets.isEmpty else {
                    let errorMessage = "No OSC packets were parsed from incoming TCP data. This is likely the result of malformed data."
                    report(error: .malformed(errorMessage), forMalformedData: Data(data), remoteHost: remoteHost, remotePort: remotePort)
                    return
                }

                dispatch(receivedPackets: packets, remoteHost: remoteHost, remotePort: remotePort)
            } catch {
                let errorMessage = "OSC 1.1 SLIP decoding error: \(error)"
                report(error: .malformed(errorMessage), forMalformedData: Data(data), remoteHost: remoteHost, remotePort: remotePort)
                return
            }

        case .none:
            // TODO: data may contain more than one OSC packet - need to figure out how to either parse out multiple consecutive OSC bundles/messages from raw data, or somehow intuit packet byte offsets within the data if possible.
            let packets = [data]
            dispatch(receivedPackets: packets, remoteHost: remoteHost, remotePort: remotePort)
        }
    }
}
