//
//  IPUtils IPAddress.swift
//  SwiftOSC Core • https://github.com/orchetect/swift-osc-core
//  © 2026 Steffan Andrews • Licensed under MIT License
//

extension IPUtils {
    public enum IPAddress: Equatable, Hashable, Sendable {
        case v4(String)
        case v6(String)
        
        public var protocolFamily: IPProtocolFamily {
            switch self {
            case .v4(_): .ipv4
            case .v6(_): .ipv6
            }
        }
    }
}
