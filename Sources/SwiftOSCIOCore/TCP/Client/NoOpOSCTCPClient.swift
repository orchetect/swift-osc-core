//
//  NoOpOSCTCPClient.swift
//  SwiftOSC Core • https://github.com/orchetect/swift-osc-core
//  © 2026 Steffan Andrews • Licensed under MIT License
//

import class Foundation.DispatchQueue
import typealias Foundation.TimeInterval

/// A no-op OSC TCP client implementation provided for testing or mocking.
open class NoOpOSCTCPClient: OSCTCPClientProtocol {
    required public init(
        remoteHost: String,
        remotePort: UInt16,
        interface: String?,
        timeTagMode: OSCTimeTagMode,
        framingMode: OSCTCPFramingMode,
        queue: DispatchQueue?,
        receiveHandler: OSCHandlerBlock?
    ) {
        // empty
    }
}

extension NoOpOSCTCPClient: @unchecked Sendable { } // TODO: unchecked

// MARK: - Lifecycle

extension NoOpOSCTCPClient {
    public func connect(timeout: TimeInterval) throws { }

    public func close() { }
}

// MARK: - Communication

extension NoOpOSCTCPClient {
    public func send(_ packet: OSCPacket) throws { }

    public func send(_ bundle: OSCBundle) throws { }

    public func send(_ message: OSCMessage) throws { }
}

// MARK: - Properties

extension NoOpOSCTCPClient {
    public var timeTagMode: OSCTimeTagMode {
        get { .ignore }
        set { /* empty */ }
    }

    public var remoteHost: String {
        ""
    }

    public var remotePort: UInt16 {
        0
    }

    public var interface: String? {
        nil
    }

    public var isConnected: Bool {
        false
    }

    public var framingMode: OSCTCPFramingMode {
        .osc1_1
    }

    public func setReceiveHandler(_ handler: OSCHandlerBlock?) { }

    public func setNotificationHandler(_ handler: NotificationHandlerBlock?) { }
}
