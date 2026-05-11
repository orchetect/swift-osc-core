//
//  OSCUDPSocket API Tests.swift
//  SwiftOSC Core • https://github.com/orchetect/swift-osc-core
//  © 2026 Steffan Andrews • Licensed under MIT License
//

import SwiftOSCIO
import Testing

/// No functionality tests, just test that standardized API access compiles as expected.
@Suite
struct OSCUDPSocket_API_Tests {
    @Test
    func udpSocketAccess() {
        let oscSocket = OSCUDPSocket()
        
        _ = oscSocket.isStarted
        _ = oscSocket.localPort
        // oscSocket.localPort = 9000 // immutable actor
        _ = oscSocket.remoteHost
        // oscSocket.remoteHost = "192.168.0.10" // immutable actor
        _ = oscSocket.remotePort
        // oscSocket.remotePort = 8000 // immutable actor
        _ = oscSocket.isIPv4BroadcastEnabled
        // oscSocket.isIPv4BroadcastEnabled = true // immutable actor
        oscSocket.setReceiveHandler { message, timeTag, host, port in
            print(message)
        }
        // oscSocket.receiveHandler = { _,_ in } // immutable, use `setReceiveHandler()` instead
        
        _ = OSCUDPSocket(localPort: 8009)
        _ = OSCUDPSocket(localPort: 8010) { message, timeTag, host, port in
            print(message)
        }
        _ = OSCUDPSocket(localPort: 8011, timeTagMode: .ignore) { message, timeTag, host, port in
            print(message)
        }
        _ = OSCUDPSocket(
            localPort: 8012,
            timeTagMode: .ignore
        ) { message, timeTag, host, port in
            print(message)
        }
        _ = OSCUDPSocket(
            localPort: 8013,
            timeTagMode: .ignore,
            isIPv4BroadcastEnabled: true
        ) { message, timeTag, host, port in
            print(message)
        }
        _ = OSCUDPSocket(
            localPort: 8014,
            remoteHost: "192.168.0.10",
            remotePort: 8000,
            timeTagMode: .ignore,
            isIPv4BroadcastEnabled: true
        ) { message, timeTag, host, port in
            print(message)
        }
    }
}
