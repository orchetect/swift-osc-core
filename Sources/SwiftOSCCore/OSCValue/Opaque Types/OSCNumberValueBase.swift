//
//  OSCNumberValueBase.swift
//  SwiftOSC Core • https://github.com/orchetect/swift-osc-core
//  © 2026 Steffan Andrews • Licensed under MIT License
//

/// Type-erased OSC number value encapsulation.
public enum OSCNumberValueBase {
    /// Boolean value.
    case bool(Bool)

    /// Integer value.
    case int(any(OSCValue & BinaryInteger))

    /// Floating-point value.
    case float(any(OSCValue & BinaryFloatingPoint))
}

// MARK: - Equatable

extension OSCNumberValueBase: Equatable {
    public static func == (lhs: OSCNumberValueBase, rhs: OSCNumberValueBase) -> Bool {
        lhs.anyHashable() == rhs.anyHashable()
    }
}

// MARK: - Hashable

extension OSCNumberValueBase: Hashable {
    public func hash(into hasher: inout Hasher) {
        switch self {
        case let .bool(v):
            hasher.combine(v)
        case let .int(v):
            hasher.combine(v)
        case let .float(v):
            hasher.combine(v)
        }
    }
}

extension OSCNumberValueBase {
    /// Unwraps the base value and returns it as an `AnyHashable` instance.
    public func anyHashable() -> AnyHashable {
        switch self {
        case let .bool(v):
            AnyHashable(v)
        case let .int(v):
            AnyHashable(v)
        case let .float(v):
            AnyHashable(v)
        }
    }
}

// MARK: - Sendable

extension OSCNumberValueBase: Sendable { }

// MARK: - CustomStringConvertible

extension OSCNumberValueBase: CustomStringConvertible {
    public var description: String {
        switch self {
        case let .bool(v):
            "\(v)"
        case let .int(v):
            "\(v)"
        case let .float(v):
            "\(v)"
        }
    }
}

// MARK: - Metadata Properties

extension OSCNumberValueBase {
    /// Returns a boolean value indicating whether the wrapped value type is `Bool`.
    ///
    /// This property is provided as a convenient alternative to unwrapping the enum case
    /// simply to determine its underlying concrete type.
    public var isBool: Bool {
        switch self {
        case .bool:
            true
        default:
            false
        }
    }

    /// Returns a boolean value indicating whether the wrapped value type is an integer.
    ///
    /// This property is provided as a convenient alternative to unwrapping the enum case
    /// simply to determine its underlying concrete type.
    public var isInteger: Bool {
        switch self {
        case .int:
            true
        default:
            false
        }
    }

    /// Returns a boolean value indicating whether the wrapped value type is a floating-point number.
    ///
    /// This property is provided as a convenient alternative to unwrapping the enum case
    /// simply to determine its underlying concrete type.
    public var isFloat: Bool {
        switch self {
        case .float:
            true
        default:
            false
        }
    }
}
