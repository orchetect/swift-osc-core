//
//  OSCUDPClient API Tests.swift
//  SwiftOSC Core • https://github.com/orchetect/swift-osc-core
//  © 2026 Steffan Andrews • Licensed under MIT License
//

import SwiftOSCIO
import Testing

/// No functionality tests, just test that standardized API access compiles as expected.
@Suite
struct OSCUDPClient_API_Tests {
    @Test
    func udpClientAccess() {
        let oscClient = OSCUDPClient()
        
        oscClient.isIPv4BroadcastEnabled = true
        oscClient.isIPv4BroadcastEnabled = false
        oscClient.isPortReuseEnabled = true
        oscClient.isPortReuseEnabled = false
        
        _ = OSCUDPClient(localPort: 8002)
        _ = OSCUDPClient(localPort: 8003, isPortReuseEnabled: true)
        _ = OSCUDPClient(localPort: 8004, isPortReuseEnabled: true, isIPv4BroadcastEnabled: true)
        _ = OSCUDPClient(localPort: 8005, isIPv4BroadcastEnabled: true)
    }
}
