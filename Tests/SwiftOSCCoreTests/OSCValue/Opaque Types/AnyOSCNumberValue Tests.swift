//
//  AnyOSCNumberValue Tests.swift
//  SwiftOSC Core • https://github.com/orchetect/swift-osc-core
//  © 2026 Steffan Andrews • Licensed under MIT License
//

import Foundation
@testable import SwiftOSCCore
import Testing

@Suite
struct AnyOSCNumberValue_Tests {
    // MARK: - boolValue

    @Test
    func bool_boolValue() {
        #expect(AnyOSCNumberValue(true as Bool).boolValue == true)
        #expect(AnyOSCNumberValue(false as Bool).boolValue == false)
    }

    @Test
    func int_boolValue() {
        #expect(AnyOSCNumberValue(-1 as Int).boolValue == false)
        #expect(AnyOSCNumberValue(0 as Int).boolValue == false)
        #expect(AnyOSCNumberValue(1 as Int).boolValue == true)
        #expect(AnyOSCNumberValue(2 as Int).boolValue == true)
    }

    @Test
    func int32_boolValue() {
        #expect(AnyOSCNumberValue(-1 as Int32).boolValue == false)
        #expect(AnyOSCNumberValue(0 as Int32).boolValue == false)
        #expect(AnyOSCNumberValue(1 as Int32).boolValue == true)
        #expect(AnyOSCNumberValue(2 as Int32).boolValue == true)
    }

    @Test
    func float_boolValue() {
        #expect(AnyOSCNumberValue(-1.0 as Float).boolValue == false)
        #expect(AnyOSCNumberValue(0.0 as Float).boolValue == false)
        #expect(AnyOSCNumberValue(0.99 as Float).boolValue == false)
        #expect(AnyOSCNumberValue(1.0 as Float).boolValue == true)
        #expect(AnyOSCNumberValue(2.0 as Float).boolValue == true)
    }

    @Test
    func double_boolValue() {
        #expect(AnyOSCNumberValue(-1.0 as Double).boolValue == false)
        #expect(AnyOSCNumberValue(0.0 as Double).boolValue == false)
        #expect(AnyOSCNumberValue(0.99 as Double).boolValue == false)
        #expect(AnyOSCNumberValue(1.0 as Double).boolValue == true)
        #expect(AnyOSCNumberValue(2.0 as Double).boolValue == true)
    }

    // MARK: - intValue

    @Test
    func bool_intValue() {
        #expect(AnyOSCNumberValue(true as Bool).intValue == 1)
        #expect(AnyOSCNumberValue(false as Bool).intValue == 0)
    }

    @Test
    func int_intValue() {
        #expect(AnyOSCNumberValue(-1 as Int).intValue == -1)
        #expect(AnyOSCNumberValue(0 as Int).intValue == 0)
        #expect(AnyOSCNumberValue(1 as Int).intValue == 1)
        #expect(AnyOSCNumberValue(2 as Int).intValue == 2)
    }

    @Test
    func int32_intValue() {
        #expect(AnyOSCNumberValue(-1 as Int32).intValue == -1)
        #expect(AnyOSCNumberValue(0 as Int32).intValue == 0)
        #expect(AnyOSCNumberValue(1 as Int32).intValue == 1)
        #expect(AnyOSCNumberValue(2 as Int32).intValue == 2)
    }

    @Test
    func float_intValue() {
        #expect(AnyOSCNumberValue(-1.0 as Float).intValue == -1)
        #expect(AnyOSCNumberValue(0.0 as Float).intValue == 0)
        #expect(AnyOSCNumberValue(0.99 as Float).intValue == 0)
        #expect(AnyOSCNumberValue(1.0 as Float).intValue == 1)
        #expect(AnyOSCNumberValue(2.0 as Float).intValue == 2)
    }

    @Test
    func double_intValue() {
        #expect(AnyOSCNumberValue(-1.0 as Double).intValue == -1)
        #expect(AnyOSCNumberValue(0.0 as Double).intValue == 0)
        #expect(AnyOSCNumberValue(0.99 as Double).intValue == 0)
        #expect(AnyOSCNumberValue(1.0 as Double).intValue == 1)
        #expect(AnyOSCNumberValue(2.0 as Double).intValue == 2)
    }

    // MARK: - floatValue

    @Test
    func bool_floatValue() {
        #expect(AnyOSCNumberValue(true as Bool).floatValue == 1.0)
        #expect(AnyOSCNumberValue(false as Bool).floatValue == 0.0)
    }

    @Test
    func int_floatValue() {
        #expect(AnyOSCNumberValue(-1 as Int).floatValue == -1.0)
        #expect(AnyOSCNumberValue(0 as Int).floatValue == 0.0)
        #expect(AnyOSCNumberValue(1 as Int).floatValue == 1.0)
        #expect(AnyOSCNumberValue(2 as Int).floatValue == 2.0)
    }

    @Test
    func int32_floatValue() {
        #expect(AnyOSCNumberValue(-1 as Int32).floatValue == -1.0)
        #expect(AnyOSCNumberValue(0 as Int32).floatValue == 0.0)
        #expect(AnyOSCNumberValue(1 as Int32).floatValue == 1.0)
        #expect(AnyOSCNumberValue(2 as Int32).floatValue == 2.0)
    }

    @Test
    func float_floatValue() {
        #expect(AnyOSCNumberValue(-1.0 as Float).floatValue == -1.0)
        #expect(AnyOSCNumberValue(0.0 as Float).floatValue == 0.0)
        #expect(AnyOSCNumberValue(0.99 as Float).floatValue == 0.99)
        #expect(AnyOSCNumberValue(1.0 as Float).floatValue == 1.0)
        #expect(AnyOSCNumberValue(2.0 as Float).floatValue == 2.0)
    }

    @Test
    func double_floatValue() {
        #expect(AnyOSCNumberValue(-1.0 as Double).floatValue == -1.0)
        #expect(AnyOSCNumberValue(0.0 as Double).floatValue == 0.0)
        #expect(AnyOSCNumberValue(0.99 as Double).floatValue == 0.99)
        #expect(AnyOSCNumberValue(1.0 as Double).floatValue == 1.0)
        #expect(AnyOSCNumberValue(2.0 as Double).floatValue == 2.0)
    }

    // MARK: - doubleValue

    @Test
    func bool_doubleValue() {
        #expect(AnyOSCNumberValue(true as Bool).doubleValue == 1.0)
        #expect(AnyOSCNumberValue(false as Bool).doubleValue == 0.0)
    }

    @Test
    func int_doubleValue() {
        #expect(AnyOSCNumberValue(-1 as Int).doubleValue == -1.0)
        #expect(AnyOSCNumberValue(0 as Int).doubleValue == 0.0)
        #expect(AnyOSCNumberValue(1 as Int).doubleValue == 1.0)
        #expect(AnyOSCNumberValue(2 as Int).doubleValue == 2.0)
    }

    @Test
    func int32_doubleValue() {
        #expect(AnyOSCNumberValue(-1 as Int32).doubleValue == -1.0)
        #expect(AnyOSCNumberValue(0 as Int32).doubleValue == 0.0)
        #expect(AnyOSCNumberValue(1 as Int32).doubleValue == 1.0)
        #expect(AnyOSCNumberValue(2 as Int32).doubleValue == 2.0)
    }

    @Test
    func float_doubleValue() {
        #expect(AnyOSCNumberValue(-1.0 as Float).doubleValue == -1.0)
        #expect(AnyOSCNumberValue(0.0 as Float).doubleValue == 0.0)
        #expect(AnyOSCNumberValue(0.5 as Float).doubleValue == 0.5)
        #expect(AnyOSCNumberValue(1.0 as Float).doubleValue == 1.0)
        #expect(AnyOSCNumberValue(2.0 as Float).doubleValue == 2.0)
    }

    @Test
    func double_doubleValue() {
        #expect(AnyOSCNumberValue(-1.0 as Double).doubleValue == -1.0)
        #expect(AnyOSCNumberValue(0.0 as Double).doubleValue == 0.0)
        #expect(AnyOSCNumberValue(0.99 as Double).doubleValue == 0.99)
        #expect(AnyOSCNumberValue(1.0 as Double).doubleValue == 1.0)
        #expect(AnyOSCNumberValue(2.0 as Double).doubleValue == 2.0)
    }

    // MARK: - isBool / isInteger / isFloat

    @Test
    func bool_Properties() {
        #expect(AnyOSCNumberValue(true as Bool).isBool)
        #expect(!AnyOSCNumberValue(true as Bool).isInteger)
        #expect(!AnyOSCNumberValue(true as Bool).isFloat)
    }

    @Test
    func int_Properties() {
        #expect(!AnyOSCNumberValue(2 as Int).isBool)
        #expect(AnyOSCNumberValue(2 as Int).isInteger)
        #expect(!AnyOSCNumberValue(2 as Int).isFloat)
    }

    @Test
    func int32_Properties() {
        #expect(!AnyOSCNumberValue(2 as Int32).isBool)
        #expect(AnyOSCNumberValue(2 as Int32).isInteger)
        #expect(!AnyOSCNumberValue(2 as Int32).isFloat)
    }

    @Test
    func float_Properties() {
        #expect(!AnyOSCNumberValue(2.5 as Float).isBool)
        #expect(!AnyOSCNumberValue(2.5 as Float).isInteger)
        #expect(AnyOSCNumberValue(2.5 as Float).isFloat)
    }

    @Test
    func double_Properties() {
        #expect(!AnyOSCNumberValue(2.5 as Double).isBool)
        #expect(!AnyOSCNumberValue(2.5 as Double).isInteger)
        #expect(AnyOSCNumberValue(2.5 as Double).isFloat)
    }
}
