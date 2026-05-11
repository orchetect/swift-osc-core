//
//  OSCUDPServer API Tests.swift
//  SwiftOSC Core • https://github.com/orchetect/swift-osc-core
//  © 2026 Steffan Andrews • Licensed under MIT License
//

import SwiftOSCIO
import Testing

/// No functionality tests, just test that standardized API access compiles as expected.
@Suite
struct OSCUDPServer_API_Tests {
    @Test
    func udpServerAccess() {
        let oscServer = OSCUDPServer()
        
        _ = oscServer.isStarted
        _ = oscServer.localPort
        // oscServer.localPort = 9000 // immutable actor
        oscServer.isPortReuseEnabled = true
        oscServer.isPortReuseEnabled = false
        oscServer.setReceiveHandler { message, timeTag, host, port in
            print(message)
        }
        // oscServer.receiveHandler = { _,_ in } // immutable actor, use `setReceiveHandler()` instead
        
        _ = OSCUDPServer(port: 8006) { message, timeTag, host, port in
            print(message)
        }
        _ = OSCUDPServer(port: 8007, timeTagMode: .ignore) { message, timeTag, host, port in
            print(message)
        }
    }
}
