//
//  Component.swift
//  SwiftOSC Core • https://github.com/orchetect/swift-osc-core
//  © 2026 Steffan Andrews • Licensed under MIT License
//

extension OSCAddressPattern {
    /// OSC Address Component.
    /// A tokenized pattern of an individual path component in an OSC address pattern.
    ///
    /// For a detailed discussion on OSC address pattern matching, see the inline documentation for
    /// `OSCAddressPattern`.
    struct Component {
        var tokens: [Token] = []

        init() { }
    }
}

extension OSCAddressPattern.Component: Equatable { }

extension OSCAddressPattern.Component: Hashable { }

extension OSCAddressPattern.Component: Sendable { }
