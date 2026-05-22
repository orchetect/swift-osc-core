//
//  IPUtils+Public.swift
//  SwiftOSC Core • https://github.com/orchetect/swift-osc-core
//  © 2026 Steffan Andrews • Licensed under MIT License
//

import struct Foundation.Data
import class Foundation.NSArray

extension IPUtils {
    public enum ResolveError: Error {
        case emptyHostname
        case noFamiliesSpecified
        case error(code: Int? = nil, reason: String)
    }
    
    /// Performs a lookup of the specified host or IP address and returns all known hostnames associated with it.
    public static func hostnames(forHostnameOrIPAddress host: String) throws -> [String] {
        guard !host.isEmpty else { throw ResolveError.emptyHostname }
        
        var ipStrings: [String] = []
        
        try CIPUtils.sockaddrIterator(forHostnameOrIPAddress: host, port: 1) { addr, length in
            if let ipString = CIPUtils.string(for: addr, length: length, property: .hostname),
               !ipStrings.contains(ipString)
            {
                ipStrings.append(ipString)
            }
            return true
        }
        
        return ipStrings
    }
    
    /// Performs a lookup of the specified host or IP address and returns all known IP addresses associated with it.
    public static func ipAddresses(forHostnameOrIPAddress host: String, families: Set<AddressFamily> = .all) throws -> [IPAddress] {
        guard !host.isEmpty else { throw ResolveError.emptyHostname }
        guard !families.isEmpty else { throw ResolveError.noFamiliesSpecified }
        
        var ipAddresses: [IPAddress] = []
        
        try CIPUtils.sockaddrIterator(forHostnameOrIPAddress: host, port: 1) { addr, length in
            guard let family = AddressFamily(from: addr.pointee.sa_family) else { return true } // continue iterator
            guard families.contains(family) else { return true } // continue iterator
            
            guard let string = CIPUtils.string(for: addr, length: length, property: .ipAddress) else { return true } // continue iterator
            
            let ipAddress: IPAddress? = switch family {
            case .ipv4: .v4(string)
            case .ipv6: .v6(string)
            case .unix: nil
            }
            
            guard let ipAddress else { return true } // continue iterator
            
            if !ipAddresses.contains(ipAddress) { ipAddresses.append(ipAddress) }
            
            return true // continue iterator
        }
        
        return ipAddresses
    }
    
    /// Performs a lookup of the specified host or IP address and returns the first known IP address associated with it
    /// matching the specified family.
    public static func ipAddress(forHostnameOrIPAddress host: String, family: AddressFamily) throws -> String? {
        guard !host.isEmpty else { throw ResolveError.emptyHostname }
        
        var ipAddress: String? = nil
        try CIPUtils.sockaddrIterator(forHostnameOrIPAddress: host, port: 1) { addr, length in
            guard let addrFamily = AddressFamily(from: addr.pointee.sa_family) else { return true } // continue iterator
            guard addrFamily == family else { return true } // continue iterator
            guard let string = CIPUtils.string(for: addr, length: length, property: .ipAddress) else { return true } // continue iterator
            ipAddress = string
            return false // exit iterator
        }
        
        guard let ipAddress else { return nil }
        return ipAddress
    }
    
    /// Performs a lookup of the specified host or IP address and returns the first known IP address associated with it
    /// matching the specified family.
    /// If the lookup returns no initial matches, all hostnames associated are used to find additional IP addresses that
    /// match the specified family.
    ///
    /// For example, if `::1` is passed as the `host` and the desired family is IPv4, this method will reverse-lookup hostnames
    /// which in most cases will include `localhost`, which in turn provides the IPv4 family address `127.0.0.1` which is then returned.
    public static func ipAddressUsingReverseLookup(
        forHostnameOrIPAddress host: String,
        forceHostnameLookup: Bool = false,
        family: AddressFamily
    ) throws -> String? {
        guard !host.isEmpty else { throw ResolveError.emptyHostname }
        
        func basicResolve() throws -> String? {
            try ipAddress(forHostnameOrIPAddress: host, family: family)
        }
        
        func firstResultFromHostnames() throws -> String? {
            try hostnames(forHostnameOrIPAddress: host)
                .lazy
                .compactMap { try IPUtils.ipAddress(forHostnameOrIPAddress: $0, family: family) }
                .first
        }
        
        return if forceHostnameLookup {
            try firstResultFromHostnames() ?? basicResolve()
        } else {
            try basicResolve() ?? firstResultFromHostnames()
        }
    }
}
