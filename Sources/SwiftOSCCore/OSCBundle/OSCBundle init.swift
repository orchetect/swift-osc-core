//
//  OSCBundle init.swift
//  SwiftOSC Core • https://github.com/orchetect/swift-osc-core
//  © 2026 Steffan Andrews • Licensed under MIT License
//

// NOTE: Overloads that take variadic values were tested,
// however for code consistency and conventional indentation, it is
// undesirable to have variadic parameters.

extension OSCBundle {
    /// OSC Bundle.
    public init(
        timeTag: OSCTimeTag? = nil,
        _ elements: [OSCPacket] = []
    ) {
        self.timeTag = timeTag ?? .init(1)
        self.elements = elements
        _rawData = nil
    }
}
