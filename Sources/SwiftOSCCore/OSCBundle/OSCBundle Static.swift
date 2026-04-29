//
//  OSCBundle Static.swift
//  SwiftOSC Core • https://github.com/orchetect/swift-osc-core
//  © 2026 Steffan Andrews • Licensed under MIT License
//

#if canImport(Darwin)
import struct Foundation.Data
#else
import struct FoundationEssentials.Data
#endif

extension OSCBundle {
    /// Enum describing the OSC packet type.
    public static let packetType: OSCPacketType = .bundle

    /// Constant caching an OSCBundle header.
    public static let header: Data = {
        guard let data = "#bundle".toData(using: .nonLossyASCII) else {
            assertionFailure("Failed to form OSC bundle header data.")
            return Data()
        }

        return OSCMessageEncoder.fourNullBytePadded(data)
    }()
}
