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

enum CFNetworkUtils {
    /// Internal:
    /// Queries the system and returns an `NSArray` containing all the socket addresses (`sockaddr`) for the given hostname or IP address.
    nonisolated
    static func sockaddrDataArray(
        forHostnameOrIPAddress host: String,
        info infoTypes: Set<CFHostInfoType> = [.addresses],
        timeout: TimeInterval = 5.0
    ) -> NSArray? {
        // sanitize inputs
        let timeout = max(1.0, timeout)
        
        let host = CFHostCreateWithName(nil, host as CFString).takeRetainedValue()
        
        // Xcode 26 building on macOS 26 throws purple runtime warnings about
        // thread priority inversion when calling CFHostStartInfoResolution
        // synchronously. Using a dispatch group to offload the work and wait
        // synchronously is one potential solution without introducing async/await.
        //
        // Adding the DispatchGroup only adds an 8.6% performance overhead in a debug build
        // when measuring 10,000 sequential calls with it vs. without it.
        let g = DispatchGroup()
        g.enter()
        DispatchQueue.global().async { [host] in
            for infoType in infoTypes {
                _ = CFHostStartInfoResolution(host, infoType, nil)
            }
            g.leave()
        }
        let result = g.wait(timeout: .now() + timeout)
        switch result {
        case .success: break
        case .timedOut: return nil
        }
        
        var isSuccess: DarwinBoolean = false
        guard let addresses = CFHostGetAddressing(host, &isSuccess)?
            .takeUnretainedValue() as NSArray?,
              isSuccess.boolValue
        else { return nil }
        
        return addresses
    }
}
