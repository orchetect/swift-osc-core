//
//  NoOpOSCUDPSocket.swift
//  SwiftOSC Core • https://github.com/orchetect/swift-osc-core
//  © 2026 Steffan Andrews • Licensed under MIT License
//

import class Foundation.DispatchQueue

/// A no-op OSC UDP socket implementation provided for testing, mocking, or as a stand-in on unsupported platforms.
open class NoOpOSCUDPSocket: OSCUDPSocketProtocol {
    open var timeTagMode: OSCTimeTagMode
    open var remoteHost: String?
    open private(set) var localPort: UInt16
    open var remotePort: UInt16 {
        didSet {
            if remotePort == 0 { remotePort = localPort }
        }
    }

    open private(set) var interface: String?
    open private(set) var isIPv4BroadcastEnabled: Bool
    open private(set) var isStarted: Bool = false
    var queue: DispatchQueue
    var receiveHandler: OSCHandlerBlock?

    required public init(
        localPort: UInt16?,
        remoteHost: String?,
        remotePort: UInt16?,
        interface: String?,
        timeTagMode: OSCTimeTagMode,
        isIPv4BroadcastEnabled: Bool,
        queue: DispatchQueue?,
        receiveHandler: OSCHandlerBlock?
    ) {
        self.localPort = localPort ?? 0
        self.remoteHost = remoteHost
        self.remotePort = remotePort ?? self.localPort
        self.interface = interface
        self.timeTagMode = timeTagMode
        self.isIPv4BroadcastEnabled = isIPv4BroadcastEnabled
        self.queue = queue ?? .global()
        self.receiveHandler = receiveHandler
    }

    // MARK: - Lifecycle

    open func start() throws {
        isStarted = true
    }

    open func stop() {
        isStarted = false
    }

    // MARK: - Properties

    open func setReceiveHandler(_ handler: OSCHandlerBlock?) {
        queue.sync {
            receiveHandler = handler
        }
    }
}

extension NoOpOSCUDPSocket: @unchecked Sendable { } // TODO: unchecked
