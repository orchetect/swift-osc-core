//
//  OSCPacketType.swift
//  SwiftOSC Core • https://github.com/orchetect/swift-osc-core
//  © 2026 Steffan Andrews • Licensed under MIT License
//

/// Enum describing an OSC packet type.
public enum OSCPacketType {
    case message
    case bundle
}

extension OSCPacketType: Equatable { }

extension OSCPacketType: Hashable { }

extension OSCPacketType: Sendable { }
