//
//  IPUtils SocketAddressProperty.swift
//  SwiftOSC Core • https://github.com/orchetect/swift-osc-core
//  © 2026 Steffan Andrews • Licensed under MIT License
//

import CoreFoundation

extension IPUtils {
    enum SocketAddressProperty: Int32, Equatable, Hashable, CaseIterable, Sendable {
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
    static var all: Self {
        Set(IPUtils.SocketAddressProperty.allCases)
    }
}
