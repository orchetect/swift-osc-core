//
//  OSCPacket Data Extensions.swift
//  SwiftOSC Core • https://github.com/orchetect/swift-osc-core
//  © 2026 Steffan Andrews • Licensed under MIT License
//

#if canImport(Darwin)
import protocol Foundation.DataProtocol
#else
import protocol FoundationEssentials.DataProtocol
#endif

extension DataProtocol {
    /// Test if data appears to be an OSC bundle or OSC message. (Basic validation)
    ///
    /// - Returns: An ``OSCPacketType`` case if validation succeeds.
    @inlinable
    package var oscPacketType: OSCPacketType? {
        if appearsToBeOSCBundle {
            return .bundle
        } else if appearsToBeOSCMessage {
            return .message
        }

        return nil
    }
}
