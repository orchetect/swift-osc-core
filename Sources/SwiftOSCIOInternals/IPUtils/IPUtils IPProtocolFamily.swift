//
//  IPUtils IPProtocolFamily.swift
//  SwiftOSC Core • https://github.com/orchetect/swift-osc-core
//  © 2026 Steffan Andrews • Licensed under MIT License
//

extension IPUtils {
    public enum IPProtocolFamily: Equatable, Hashable, CaseIterable, Sendable {
        case ipv4
        case ipv6

        #if !os(WASI)
        case unix
        #endif

        #if !os(Windows) && !os(WASI)
        case local
        #endif
    }
}

extension Set<IPUtils.IPProtocolFamily> {
    public static var all: Self {
        Set(IPUtils.IPProtocolFamily.allCases)
    }
}
