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
        info infoTypes: Set<CFHostInfoType> = [.addresses]
    ) -> NSArray? {
        let host = CFHostCreateWithName(nil, host as CFString).takeRetainedValue()
        
        // Building with Xcode 26 on macOS 26 throws purple runtime warnings about
        // thread priority inversion when calling CFHostStartInfoResolution
        // synchronously. Ideally there is a safe way to make this call synchronously
        // without having to introduce async/await to the public API.
        
        // wrap in a task at the current priority (usually userInteractive)
        Task.sync(priority: Task.currentPriority) {
            for infoType in infoTypes {
                // call out synchronously to sub-task at the expected priority of CFHostStartInfoResolution ("default" QoS)
                _ = await Task(priority: .medium /* a.k.a. "default" QoS */) {
                    _ = CFHostStartInfoResolution(host, infoType, nil)
                }.value
            }
        }
        
        var isSuccess: DarwinBoolean = false
        guard let addresses = CFHostGetAddressing(host, &isSuccess)?
            .takeUnretainedValue() as NSArray?,
              isSuccess.boolValue
        else { return nil }
        
        return addresses
    }
}
