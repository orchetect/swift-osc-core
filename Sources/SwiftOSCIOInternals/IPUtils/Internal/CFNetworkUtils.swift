//
//  CFNetworkUtils.swift
//  SwiftOSC Core • https://github.com/orchetect/swift-osc-core
//  © 2026 Steffan Andrews • Licensed under MIT License
//

@preconcurrency import CFNetwork
import CoreFoundation
import struct Foundation.Data
import class Foundation.NSArray
import typealias Foundation.TimeInterval
import class Foundation.NSLock

/// CFNetwork utilities.
enum CFNetworkUtils {
    /// Internal:
    /// Queries the system and returns an `NSArray` containing all the socket addresses (`sockaddr` as `Data`)
    /// for the given hostname or IP address.
    ///
    /// > Note:
    /// >
    /// > While this method works, it is not recommended as it easily causes issues with
    /// > thread priority inversion due to CFHostStartInfoResolution running at a lower QoS.
    nonisolated
    static func sockaddrNSDataNSArray(
        forHostnameOrIPAddress host: String,
        info infoTypes: Set<CFHostInfoType> = [.addresses]
    ) -> NSArray? {
        let host = CFHostCreateWithName(nil, host as CFString).takeRetainedValue()
        
        for infoType in infoTypes {
            // Building with Xcode 26 on macOS 26 throws purple runtime warnings about
            // thread priority inversion when calling CFHostStartInfoResolution
            // synchronously.
            //
            // Anecdotally, there were many scenarios where this caused deadlocks so
            // it's best not to be used.
            //
            // Ideally there is a safe way to make this call synchronously
            // without having to introduce async/await to the public API.
            
            _ = CFHostStartInfoResolution(host, infoType, nil)
        }
        
        var isSuccess: DarwinBoolean = false
        guard let addresses = CFHostGetAddressing(host, &isSuccess)?
            .takeUnretainedValue() as NSArray?,
              isSuccess.boolValue
        else { return nil }
        
        return addresses
    }
}

extension CFNetworkUtils {
    /// Internal:
    /// Iterates over sockaddr Data for the given host/IP and returns a compact-mapped array of return values.
    @discardableResult nonisolated
    static func sockaddrIterator<T>(
        forHostnameOrIPAddress host: String,
        info infoTypes: Set<CFHostInfoType> = [.addresses],
        maxCount: Int? = nil,
        _ block: (_ pointer: UnsafePointer<sockaddr>, _ length: Int) throws -> T?
    ) rethrows -> [T] {
        guard let addresses = sockaddrNSDataNSArray(forHostnameOrIPAddress: host, info: [.addresses]) else { return [] }
        var iteratorCount = 0
        var values: [T] = []
        for case let addressData as Data in addresses {
            try CIPUtils.withUnsafePointer(ofSockaddrData: addressData) { pointer in
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
        guard let addresses = sockaddrNSDataNSArray(forHostnameOrIPAddress: host, info: [.addresses]) else { return nil }
        for case let addressData as Data in addresses {
            let value = try CIPUtils.withUnsafePointer(ofSockaddrData: addressData) { pointer in
                try block(pointer, addressData.count)
            }
            if let value { return value }
        }
        return nil
    }
}
