//
//  OSCPacketHandler.swift
//  SwiftOSC Core • https://github.com/orchetect/swift-osc-core
//  © 2026 Steffan Andrews • Licensed under MIT License
//

/// Encapsulates an OSC server's packet handling block.
public enum OSCPacketHandler {
    /// Forward OSC packets immediately upon receiving.
    /// Packets are passed to the handler intact, and no scheduling is performed.
    case packets(_ handler: OSCPacketHandlerBlock)

    /// Unpack OSC bundles and schedule dispatch of its messages using the specified OSC time-tag policy.
    case messages(timeTagMode: OSCTimeTagMode = .ignore, _ handler: OSCMessageHandlerBlock)
}

extension OSCPacketHandler: Sendable { }
