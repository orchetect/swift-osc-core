//
//  OSCValueMaskError.swift
//  SwiftOSC Core • https://github.com/orchetect/swift-osc-core
//  © 2026 Steffan Andrews • Licensed under MIT License
//

#if canImport(Darwin)
import protocol Foundation.LocalizedError
#else
import protocol Foundation.LocalizedError
#endif

/// Error thrown by ``OSCValues`` `masked(...)` methods.
public enum OSCValueMaskError: LocalizedError, Equatable, Hashable {
    case invalidCount
    case mismatchedTypes

    public var errorDescription: String? {
        switch self {
        case .invalidCount:
            "Invalid argument count"
        case .mismatchedTypes:
            "Mismatched types"
        }
    }
}
