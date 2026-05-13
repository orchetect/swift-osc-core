//
//  OSCTCPGeneratesServerNotificationsProtocol.swift
//  SwiftOSC Core • https://github.com/orchetect/swift-osc-core
//  © 2026 Steffan Andrews • Licensed under MIT License
//

import SwiftOSCIOCore

/// Protocol adopted by OSC TCP classes that generate server notifications.
public protocol OSCTCPGeneratesServerNotificationsProtocol {
    func generateConnectedNotification(
        remoteHost: String,
        remotePort: UInt16,
        clientID: OSCTCPClientSessionID
    )

    func generateDisconnectedNotification(
        remoteHost: String,
        remotePort: UInt16,
        clientID: OSCTCPClientSessionID,
        error: (any Error)?
    )
}
