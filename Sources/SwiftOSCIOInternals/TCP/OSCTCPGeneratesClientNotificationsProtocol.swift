//
//  OSCTCPGeneratesClientNotificationsProtocol.swift
//  SwiftOSC Core • https://github.com/orchetect/swift-osc-core
//  © 2026 Steffan Andrews • Licensed under MIT License
//

/// Protocol adopted by OSC TCP classes that generate client notifications.
public protocol OSCTCPGeneratesClientNotificationsProtocol {
    func generateConnectedNotification()

    func generateDisconnectedNotification(
        error: (any Error)?
    )
}
