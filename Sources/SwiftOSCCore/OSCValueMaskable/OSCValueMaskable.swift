//
//  OSCValueMaskable.swift
//  SwiftOSC Core • https://github.com/orchetect/swift-osc-core
//  © 2026 Steffan Andrews • Licensed under MIT License
//

/// Protocol which all maskable ``OSCValue`` types conform.
public protocol OSCValueMaskable: SendableMetatype {
    /// Token describing the OSC value's OSC type.
    static var oscValueToken: OSCValueToken { get }
}

extension OSCValueMaskable {
    /// Token describing the OSC value's OSC type.
    public var oscValueToken: OSCValueToken {
        Self.oscValueToken
    }
}
