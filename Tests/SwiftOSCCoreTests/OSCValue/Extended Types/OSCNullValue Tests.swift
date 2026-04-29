//
//  OSCNullValue Tests.swift
//  SwiftOSC Core • https://github.com/orchetect/swift-osc-core
//  © 2026 Steffan Andrews • Licensed under MIT License
//

import SwiftOSCCore
import Testing

@Suite
struct OSCNullValue_Tests {
    // MARK: - `any OSCValue` Constructors

    @Test
    func oscValue_null() {
        let val: any OSCValue = .null
        #expect(val as? OSCNullValue == OSCNullValue())
    }
}
