//
//  Optional.swift
//  SwiftOSC Core • https://github.com/orchetect/swift-osc-core
//  © 2026 Steffan Andrews • Licensed under MIT License
//

// MARK: - SwiftOSCOptional

/// Protocol describing an optional, used to enable extensions on types such as `Type<T>?`.
package protocol SwiftOSCOptional {
    associatedtype Wrapped

    /// Semantic workaround used to enable extensions on types such as `Type<T>?
    @inlinable
    var optional: Wrapped? { get }
}

extension SwiftOSCOptional {
    /// Same as `Wrapped?.none`.
    @inlinable
    package static var noneValue: Wrapped? {
        .none
    }
}

extension Optional: SwiftOSCOptional {
    @inlinable
    package var optional: Wrapped? {
        self
    }
}
