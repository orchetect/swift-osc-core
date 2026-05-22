//
//  IPUtils SocketAddressProperty.swift
//  SwiftOSC Core • https://github.com/orchetect/swift-osc-core
//  © 2026 Steffan Andrews • Licensed under MIT License
//

import Foundation

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
