//
//  IPUtils SocketAddressProperty.swift
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
    public enum SocketAddressProperty: Int32, Equatable, Hashable, CaseIterable, Sendable {
        case hostname
        case ipAddress

        public var rawValue: Int32 {
            switch self {
            case .hostname: NI_NUMERICSERV
            case .ipAddress: NI_NUMERICHOST
            }
        }
    }
}

extension Set<IPUtils.SocketAddressProperty> {
    public static var all: Self {
        Set(IPUtils.SocketAddressProperty.allCases)
    }
}
