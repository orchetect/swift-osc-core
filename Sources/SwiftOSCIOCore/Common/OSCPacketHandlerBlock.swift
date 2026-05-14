//
//  OSCPacketHandlerBlock.swift
//  SwiftOSC Core • https://github.com/orchetect/swift-osc-core
//  © 2026 Steffan Andrews • Licensed under MIT License
//

/// Received-packet handler closure used by SwiftOSC I/O socket classes.
public typealias OSCPacketHandlerBlock = @Sendable (
    _ packet: OSCPacket,
    _ host: String,
    _ port: UInt16
) -> Void
