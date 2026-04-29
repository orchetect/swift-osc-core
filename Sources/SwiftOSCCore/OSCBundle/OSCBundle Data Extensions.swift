//
//  OSCBundle Data Extensions.swift
//  SwiftOSC Core • https://github.com/orchetect/swift-osc-core
//  © 2026 Steffan Andrews • Licensed under MIT License
//

#if canImport(Darwin)
import protocol Foundation.DataProtocol
#else
import protocol FoundationEssentials.DataProtocol
#endif

extension DataProtocol {
    /// A fast function to test if Data() begins with an OSC bundle header
    /// (Note: Does NOT do extensive checks to ensure data block isn't malformed)
    @inlinable
    package var appearsToBeOSCBundle: Bool {
        starts(with: OSCBundle.header)
    }
}
