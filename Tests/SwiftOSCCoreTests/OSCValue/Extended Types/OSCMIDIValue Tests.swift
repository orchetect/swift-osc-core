//
//  OSCMIDIValue Tests.swift
//  SwiftOSC Core • https://github.com/orchetect/swift-osc-core
//  © 2026 Steffan Andrews • Licensed under MIT License
//

import SwiftOSCCore
import Testing

@Suite
struct OSCMIDIValue_Tests {
    // MARK: - `any OSCValue` Constructors

    @Test
    func oscValue_midi() {
        let val: any OSCValue = .midi(portID: 0x01, status: 0x90, data1: 0x02, data2: 0x03)
        #expect(
            val as? OSCMIDIValue ==
                OSCMIDIValue(portID: 0x01, status: 0x90, data1: 0x02, data2: 0x03)
        )
    }
}
