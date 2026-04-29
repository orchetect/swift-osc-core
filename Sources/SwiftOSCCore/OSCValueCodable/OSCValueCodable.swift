//
//  OSCValueCodable.swift
//  SwiftOSC Core • https://github.com/orchetect/swift-osc-core
//  © 2026 Steffan Andrews • Licensed under MIT License
//

/// Combined protocol that includes ``OSCValueEncodable`` & ``OSCValueDecodable``.
public protocol OSCValueCodable: OSCValueEncodable & OSCValueDecodable {
    /// Declarative description of how an OSC value represents itself with OSC message type tag(s).
    static var oscTagIdentity: OSCValueTagIdentity { get }
}
