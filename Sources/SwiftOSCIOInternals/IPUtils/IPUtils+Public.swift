//
//  IPUtils+Public.swift
//  SwiftOSC Core • https://github.com/orchetect/swift-osc-core
//  © 2026 Steffan Andrews • Licensed under MIT License
//

import struct Foundation.Data
import class Foundation.NSArray
import CoreFoundation
import CFNetwork

extension IPUtils {
    public static func hostnames(forHostnameOrIPAddress host: String) -> [String] {
        guard let addresses = CFNetworkUtils.sockaddrDataArray(forHostnameOrIPAddress: host, info: [.addresses])
        else { return [] }
        
        var ipStrings: [String] = []
        for case let addressData as Data in addresses {
            guard let ipString = string(for: addressData, property: .hostname) else { continue }
            if !ipStrings.contains(ipString) { ipStrings.append(ipString) }
        }
        return ipStrings
    }
    
    public static func ipAddresses(forHostnameOrIPAddress host: String, families: Set<AddressFamily> = .all) -> [IPAddress] {
        var ipAddresses: [IPAddress] = []
        
        sockaddrIterator(forHostnameOrIPAddress: host, info: [.addresses]) { pointer, length in
            guard let family = AddressFamily(from: pointer.pointee.sa_family) else { return }
            guard families.contains(family) else { return }
            
            guard let string = string(for: pointer, length: length, property: .ipAddress) else { return }
            
            let ipAddress: IPAddress? = switch family {
            case .ipv4: .v4(string)
            case .ipv6: .v6(string)
            case .unix: nil
            }
            
            guard let ipAddress else { return }
            
            if !ipAddresses.contains(ipAddress) { ipAddresses.append(ipAddress) }
        }
        
        return ipAddresses
    }
    
    public static func ipAddress(forHostnameOrIPAddress host: String, family: AddressFamily = .ipv4) -> String? {
        let ipAddress: String? = sockaddrIterator(returning: String.self, forHostnameOrIPAddress: host, info: [.addresses]) { pointer, length in
            guard let addrFamily = AddressFamily(from: pointer.pointee.sa_family) else { return nil }
            guard addrFamily == family else { return nil }
            guard let string = string(for: pointer, length: length, property: .ipAddress) else { return nil }
            return string
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
    public static func ipAddressUsingReverseLookup(forHostnameOrIPAddress host: String, family: AddressFamily) -> String? {
        // first try resolving host or IP to an IP address of specified family
        if let ipv4Address = ipAddress(forHostnameOrIPAddress: host, family: family) {
            ipv4Address
        } else {
            // otherwise, resolve host or IP to a hostname and see if it has any alternative IP addresses of specified family
            hostnames(forHostnameOrIPAddress: host)
                .lazy
                .compactMap { IPUtils.ipAddress(forHostnameOrIPAddress: $0, family: family) }
                .first
        }
    }

}
