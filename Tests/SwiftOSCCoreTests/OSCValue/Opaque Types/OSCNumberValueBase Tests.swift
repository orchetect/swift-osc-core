//
//  OSCNumberValueBase Tests.swift
//  SwiftOSC Core • https://github.com/orchetect/swift-osc-core
//  © 2026 Steffan Andrews • Licensed under MIT License
//

import Foundation
@testable import SwiftOSCCore
import Testing

@Suite
struct OSCNumberValueBase_Tests {
    // MARK: - boolValue

    @Test
    func bool_boolValue() {
        #expect(OSCNumberValueBase.bool(true as Bool).boolValue == true)
        #expect(OSCNumberValueBase.bool(false as Bool).boolValue == false)
    }

    @Test
    func int_boolValue() {
        #expect(OSCNumberValueBase.int(-1 as Int).boolValue == false)
        #expect(OSCNumberValueBase.int(0 as Int).boolValue == false)
        #expect(OSCNumberValueBase.int(1 as Int).boolValue == true)
        #expect(OSCNumberValueBase.int(2 as Int).boolValue == true)
    }

    @Test
    func int32_boolValue() {
        #expect(OSCNumberValueBase.int(-1 as Int32).boolValue == false)
        #expect(OSCNumberValueBase.int(0 as Int32).boolValue == false)
        #expect(OSCNumberValueBase.int(1 as Int32).boolValue == true)
        #expect(OSCNumberValueBase.int(2 as Int32).boolValue == true)
    }

    @Test
    func double_boolValue() {
        #expect(OSCNumberValueBase.float(-1.0 as Double).boolValue == false)
        #expect(OSCNumberValueBase.float(0.0 as Double).boolValue == false)
        #expect(OSCNumberValueBase.float(0.99 as Double).boolValue == false)
        #expect(OSCNumberValueBase.float(1.0 as Double).boolValue == true)
        #expect(OSCNumberValueBase.float(2.0 as Double).boolValue == true)
    }

    // MARK: - intValue

    @Test
    func bool_intValue() {
        #expect(OSCNumberValueBase.bool(true as Bool).intValue == 1)
        #expect(OSCNumberValueBase.bool(false as Bool).intValue == 0)
    }

    @Test
    func int_intValue() {
        #expect(OSCNumberValueBase.int(-1 as Int).intValue == -1)
        #expect(OSCNumberValueBase.int(0 as Int).intValue == 0)
        #expect(OSCNumberValueBase.int(1 as Int).intValue == 1)
        #expect(OSCNumberValueBase.int(2 as Int).intValue == 2)
    }

    @Test
    func int32_intValue() {
        #expect(OSCNumberValueBase.int(-1 as Int32).intValue == -1)
        #expect(OSCNumberValueBase.int(0 as Int32).intValue == 0)
        #expect(OSCNumberValueBase.int(1 as Int32).intValue == 1)
        #expect(OSCNumberValueBase.int(2 as Int32).intValue == 2)
    }

    @Test
    func double_intValue() {
        #expect(OSCNumberValueBase.float(-1.0 as Double).intValue == -1)
        #expect(OSCNumberValueBase.float(0.0 as Double).intValue == 0)
        #expect(OSCNumberValueBase.float(0.99 as Double).intValue == 0)
        #expect(OSCNumberValueBase.float(1.0 as Double).intValue == 1)
        #expect(OSCNumberValueBase.float(2.0 as Double).intValue == 2)
    }

    // MARK: - doubleValue

    @Test
    func bool_doubleValue() {
        #expect(OSCNumberValueBase.bool(true as Bool).doubleValue == 1.0)
        #expect(OSCNumberValueBase.bool(false as Bool).doubleValue == 0.0)
    }

    @Test
    func int_doubleValue() {
        #expect(OSCNumberValueBase.int(-1 as Int).doubleValue == -1.0)
        #expect(OSCNumberValueBase.int(0 as Int).doubleValue == 0.0)
        #expect(OSCNumberValueBase.int(1 as Int).doubleValue == 1.0)
        #expect(OSCNumberValueBase.int(2 as Int).doubleValue == 2.0)
    }

    @Test
    func int32_doubleValue() {
        #expect(OSCNumberValueBase.int(-1 as Int32).doubleValue == -1.0)
        #expect(OSCNumberValueBase.int(0 as Int32).doubleValue == 0.0)
        #expect(OSCNumberValueBase.int(1 as Int32).doubleValue == 1.0)
        #expect(OSCNumberValueBase.int(2 as Int32).doubleValue == 2.0)
    }

    @Test
    func double_doubleValue() {
        #expect(OSCNumberValueBase.float(-1.0 as Double).doubleValue == -1.0)
        #expect(OSCNumberValueBase.float(0.0 as Double).doubleValue == 0.0)
        #expect(OSCNumberValueBase.float(0.99 as Double).doubleValue == 0.99)
        #expect(OSCNumberValueBase.float(1.0 as Double).doubleValue == 1.0)
        #expect(OSCNumberValueBase.float(2.0 as Double).doubleValue == 2.0)
    }

    // MARK: - isBool / isInteger / isFloat

    @Test
    func bool_Properties() {
        #expect(OSCNumberValueBase.bool(true).isBool)
        #expect(!OSCNumberValueBase.bool(true).isInteger)
        #expect(!OSCNumberValueBase.bool(true).isFloat)
    }

    @Test
    func int_Properties() {
        #expect(!OSCNumberValueBase.int(2 as Int).isBool)
        #expect(OSCNumberValueBase.int(2 as Int).isInteger)
        #expect(!OSCNumberValueBase.int(2 as Int).isFloat)
    }

    @Test
    func int32_Properties() {
        #expect(!OSCNumberValueBase.int(2 as Int32).isBool)
        #expect(OSCNumberValueBase.int(2 as Int32).isInteger)
        #expect(!OSCNumberValueBase.int(2 as Int32).isFloat)
    }

    @Test
    func double_Properties() {
        #expect(!OSCNumberValueBase.float(2.5 as Double).isBool)
        #expect(!OSCNumberValueBase.float(2.5 as Double).isInteger)
        #expect(OSCNumberValueBase.float(2.5 as Double).isFloat)
    }
}
