//
//  IPUtils AddressFamily.swift
//  SwiftOSC Core • https://github.com/orchetect/swift-osc-core
//  © 2026 Steffan Andrews • Licensed under MIT License
//

import Foundation

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
    public init?(from rawFamily: UInt8) { // a.k.a. `sa_family_t`
        guard let match = Self.allCases
            .first(where: { $0.rawValue == Int32(rawFamily) })
        else { return nil }
        
        self = match
    }
}

extension Set<IPUtils.AddressFamily> {
    public static var all: Self {
        Set(IPUtils.AddressFamily.allCases)
    }
}
