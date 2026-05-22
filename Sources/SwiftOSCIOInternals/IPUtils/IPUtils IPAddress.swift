//
//  IPUtils IPAddress.swift
//  SwiftOSC Core • https://github.com/orchetect/swift-osc-core
//  © 2026 Steffan Andrews • Licensed under MIT License
//

extension IPUtils {
    /// Network IP address (IPv4 / IPv6).
    public enum IPAddress: Equatable, Hashable, Sendable {
        /// IPv4 IP address.
        case v4(String)
        
        /// IPv6 IP address.
        case v6(String)
    }
}

extension IPUtils.IPAddress {
    /// Returns the IP protocol family for the IP address.
    public var protocolFamily: IPUtils.IPProtocolFamily {
        switch self {
        case .v4(_): .ipv4
        case .v6(_): .ipv6
        }
    }
    
    /// Returns the string representation of the IP address.
    public var string: String {
        switch self {
        case let .v4(string): string
        case let .v6(string): string
        }
    }
}
