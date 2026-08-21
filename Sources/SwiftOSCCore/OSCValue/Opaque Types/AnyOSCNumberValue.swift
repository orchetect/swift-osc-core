//
//  AnyOSCNumberValue.swift
//  SwiftOSC Core • https://github.com/orchetect/swift-osc-core
//  © 2026 Steffan Andrews • Licensed under MIT License
//

// TODO: Absorb and remove AnyOSCNumberValue by converting AnyOSCNumberValue to an enum. Rename to OSCNumberValue after.

/// A meta-type used in ``OSCValues`` `masked()` to opaquely mask any OSC number type.
/// This type is not publicly initialize-able; instead, it is provided as a box for a type-erased
/// number value when masking.
///
/// - ``base`` returns the strongly-typed number as an enum case.
/// - ``boolValue``, ``intValue``, ``floatValue`` and ``doubleValue`` can be used as a convenience
///   to access the base value, converting from the base type if necessary.
/// - ``isBool``, ``isInteger``, and ``isFloat`` can be used as a convenience to return the base
///   value's type without unwrapping it first.
public struct AnyOSCNumberValue {
    /// Base value storage.
    public let base: OSCNumberValueBase

    init(_ base: Bool) {
        self.base = .bool(base)
    }

    init(_ base: some OSCValue & BinaryInteger) {
        self.base = .int(base)
    }

    init(_ base: some OSCValue & BinaryFloatingPoint) {
        self.base = .float(base)
    }
}

// MARK: - OSCValueMaskable

@_documentation(visibility: internal)
extension AnyOSCNumberValue: OSCValueMaskable {
    public static let oscValueToken: OSCValueToken = .numberOrBool
}

// MARK: - Equatable

extension AnyOSCNumberValue: Equatable {
    // implementation is automatically synthesized by Swift
}

// MARK: - Hashable

extension AnyOSCNumberValue: Hashable {
    // implementation is automatically synthesized by Swift
}

// MARK: - Sendable

extension AnyOSCNumberValue: Sendable { }

// MARK: - CustomStringConvertible

extension AnyOSCNumberValue: CustomStringConvertible {
    public var description: String {
        "\(base)"
    }
}

// MARK: - Metadata Properties

extension AnyOSCNumberValue {
    /// Returns a boolean value indicating whether the wrapped ``base`` value type is `Bool`.
    ///
    /// This property is provided as a convenient alternative to unwrapping the ``base`` value
    /// simply to determine its underlying concrete type.
    @inline(__always)
    nonisolated
    public var isBool: Bool {
        base.isBool
    }

    /// Returns a boolean value indicating whether the wrapped ``base`` value type is an integer.
    ///
    /// This property is provided as a convenient alternative to unwrapping the ``base`` value
    /// simply to determine its underlying concrete type.
    @inline(__always)
    nonisolated
    public var isInteger: Bool {
        base.isInteger
    }

    /// Returns a boolean value indicating whether the wrapped ``base`` value type is a floating-point number.
    ///
    /// This property is provided as a convenient alternative to unwrapping the ``base`` value
    /// simply to determine its underlying concrete type.
    @inline(__always)
    nonisolated
    public var isFloat: Bool {
        base.isFloat
    }
}

// MARK: - Computed Base Value Properties

extension AnyOSCNumberValue {
    /// Returns the ``base`` value as an `Bool`, lossily converting format if necessary.
    ///
    /// Provided as a convenience. To get the actual stored value, unwrap the ``base`` enum case instead.
    ///
    /// In the event the wrapped type is numeric and not a boolean, values equal to or greater than
    /// `1` will return `true`, whereas values less than `1` (including negative values) will return
    /// `false`.
    @inline(__always)
    nonisolated
    public var boolValue: Bool {
        base.boolValue
    }

    /// Returns the ``base`` value as an `Int`, lossily converting format if necessary.
    ///
    /// Provided as a convenience. To get the actual stored value, unwrap the ``base`` enum case instead.
    @inline(__always)
    nonisolated
    public var intValue: Int {
        base.intValue
    }

    /// Returns the ``base`` value as a `Float`, lossily converting format if necessary.
    ///
    /// Provided as a convenience. To get the actual stored value, unwrap the ``base`` enum case instead.
    @inline(__always)
    nonisolated
    public var floatValue: Float {
        base.floatValue
    }

    /// Returns the ``base`` value as a `Double`, lossily converting format if necessary.
    ///
    /// Provided as a convenience. To get the actual stored value, unwrap the ``base`` enum case instead.
    @inline(__always)
    nonisolated
    public var doubleValue: Double {
        base.doubleValue
    }
}
