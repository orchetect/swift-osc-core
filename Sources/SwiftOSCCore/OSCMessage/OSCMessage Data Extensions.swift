//
//  OSCMessage Data Extensions.swift
//  SwiftOSC Core • https://github.com/orchetect/swift-osc-core
//  © 2026 Steffan Andrews • Licensed under MIT License
//

#if canImport(Darwin)
import protocol Foundation.DataProtocol
#else
import protocol FoundationEssentials.DataProtocol
#endif

extension DataProtocol {
    /// A fast test if `Data` appears to be an OSC message.
    /// (Note: Does NOT do extensive checks to ensure message isn't malformed.)
    @inlinable
    package var appearsToBeOSCMessage: Bool {
        // it's possible an OSC address won't start with "/", but it should!
        starts(with: OSCMessage.header)
    }
}
