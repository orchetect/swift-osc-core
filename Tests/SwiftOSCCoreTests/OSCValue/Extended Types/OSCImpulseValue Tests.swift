//
//  OSCImpulseValue Tests.swift
//  SwiftOSC Core • https://github.com/orchetect/swift-osc-core
//  © 2026 Steffan Andrews • Licensed under MIT License
//

import SwiftOSCCore
import Testing

@Suite
struct OSCImpulseValue_Tests {
    // MARK: - `any OSCValue` Constructors

    @Test
    func oscValue_impulse() {
        let val: any OSCValue = .impulse
        #expect(val as? OSCImpulseValue == OSCImpulseValue())
    }
}
