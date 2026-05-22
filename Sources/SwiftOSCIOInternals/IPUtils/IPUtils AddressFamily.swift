//
//  IPUtils AddressFamily.swift
//  SwiftOSC Core • https://github.com/orchetect/swift-osc-core
//  © 2026 Steffan Andrews • Licensed under MIT License
//

#if canImport(Darwin)
import Darwin
#elseif os(Linux) || os(Android)
#if canImport(Glibc)
@preconcurrency import Glibc
#elseif canImport(Musl)
@preconcurrency import Musl
#elseif canImport(Android)
@preconcurrency import Android
#endif
#elseif canImport(WASILibc)
@preconcurrency import WASILibc
#else
#error("SwiftOSC IO Internals was unable to identify the C library on the current platform.")
#endif

extension IPUtils {
    public enum AddressFamily: Int32, Equatable, Hashable, CaseIterable, Sendable {
        case ipv4
        case ipv6
        case unix

        public var rawValue: Int32 {
            switch self {
            case .ipv4: AF_INET
            case .ipv6: AF_INET6
            case .unix: AF_UNIX
            }
        }
    }
}

extension IPUtils.AddressFamily {
    // a.k.a. `sa_family_t` underlying type differs based on platform
    #if canImport(Darwin)
    public typealias PlatformInteger = UInt8
    #elseif os(Linux) || os(Android)
    public typealias PlatformInteger = UInt16
    #elseif canImport(WASILibc)
    // TODO: find out what sa_family_t aliases to for WASI
    #endif

    public init?(from rawFamily: PlatformInteger) {
        guard let match = Self.allCases
            .first(where: { $0.rawValue == RawValue(rawFamily) })
        else { return nil }

        self = match
    }
}

extension Set<IPUtils.AddressFamily> {
    public static var all: Self {
        Set(IPUtils.AddressFamily.allCases)
    }
}
