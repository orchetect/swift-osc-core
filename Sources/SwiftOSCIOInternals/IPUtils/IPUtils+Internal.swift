//
//  IPUtils+Internal.swift
//  SwiftOSC Core • https://github.com/orchetect/swift-osc-core
//  © 2026 Steffan Andrews • Licensed under MIT License
//

import struct Foundation.Data
import CoreFoundation
import CFNetwork

extension IPUtils {
    /// Internal:
    /// Iterates over sockaddr Data for the given host/IP and returns a compact-mapped array of return values.
    @discardableResult nonisolated
    static func sockaddrIterator<T>(
        forHostnameOrIPAddress host: String,
        info infoTypes: Set<CFHostInfoType> = [.addresses],
        maxCount: Int? = nil,
        _ block: (_ pointer: UnsafePointer<sockaddr>, _ length: Int) throws -> T?
    ) rethrows -> [T] {
        guard let addresses = CFNetworkUtils.sockaddrDataArray(forHostnameOrIPAddress: host, info: [.addresses]) else { return [] }
        var iteratorCount = 0
        var values: [T] = []
        for case let addressData as Data in addresses {
            try withUnsafePointer(ofSockaddrData: addressData) { pointer in
                if let value = try block(pointer, addressData.count) { values.append(value) }
            }
            iteratorCount += 1
            if let maxCount, iteratorCount >= maxCount { return values }
        }
        return values
    }
    
    /// Internal:
    /// Iterates over sockaddr Data for the given host/IP and returns the first non-nil value.
    nonisolated
    static func sockaddrIterator<T>(
        returning: T.Type,
        forHostnameOrIPAddress host: String,
        info infoTypes: Set<CFHostInfoType> = [.addresses],
        _ block: (_ pointer: UnsafePointer<sockaddr>, _ length: Int) throws -> T?
    ) rethrows -> T? {
        guard let addresses = CFNetworkUtils.sockaddrDataArray(forHostnameOrIPAddress: host, info: [.addresses]) else { return nil }
        for case let addressData as Data in addresses {
            let value = try withUnsafePointer(ofSockaddrData: addressData) { pointer in
                try block(pointer, addressData.count)
            }
            if let value { return value }
        }
        return nil
    }
    
    /// Internal:
    /// Assumes data has the memory layout of a `sockaddr` instance and provides a scoped closure to access a typed pointer.
    nonisolated
    static func withUnsafePointer<T>(
        ofSockaddrData sockaddrData: Data,
        _ block: (_ pointer: UnsafePointer<sockaddr>) throws -> T?
    ) rethrows -> T? {
        try sockaddrData.withUnsafeBytes { pointer -> T? in
            guard let baseAddress = pointer.baseAddress else { return nil }
            let p = baseAddress.assumingMemoryBound(to: sockaddr.self)
            return try block(p)
        }
    }
    
    /// Internal:
    /// Returns the string value returned from the `sockaddr` data for the given property.
    nonisolated
    static func string(for sockaddrData: Data, property: SocketAddressProperty) -> String? {
        withUnsafePointer(ofSockaddrData: sockaddrData) { pointer in
            string(for: pointer, length: sockaddrData.count, property: property)
        }
    }
    
    /// Internal:
    /// Returns the string value returned from the `sockaddr` for the given property.
    nonisolated
    static func string(for address: UnsafePointer<sockaddr>, length: Int, property: SocketAddressProperty) -> String? {
        var ipCString = [Int8](repeating: 0x00, count: Int(NI_MAXHOST))
        
        let result = getnameinfo(
            address,
            socklen_t(length),
            &ipCString,
            socklen_t(ipCString.count),
            nil,
            0,
            property.rawValue
        )
        guard result == 0 else { return nil }
        
        // decode C string
        guard let ipString = stringFromNullTerminatedCString(ipCString) else { return nil }
        return ipString
    }
    
    /// Internal:
    /// Converts a null-terminated C string to a `String`.
    @inlinable nonisolated
    static func stringFromNullTerminatedCString(_ cString: [Int8]) -> String? {
        guard let firstNullIndex = cString.firstIndex(of: 0x00) else { return nil }
        let charRange = Array(cString[cString.startIndex ... firstNullIndex])
        guard let string = String(utf8String: charRange) else { return nil }
        return string
    }
}
