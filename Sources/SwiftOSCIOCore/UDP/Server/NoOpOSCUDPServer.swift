//
//  NoOpOSCUDPServer.swift
//  SwiftOSC Core • https://github.com/orchetect/swift-osc-core
//  © 2026 Steffan Andrews • Licensed under MIT License
//

import class Foundation.DispatchQueue

/// A no-op OSC UDP server implementation provided for testing, mocking, or as a stand-in on unsupported platforms.
open class NoOpOSCUDPServer: OSCUDPServerProtocol {
    open var timeTagMode: OSCTimeTagMode
    open private(set) var localPort: UInt16
    open private(set) var interface: String?
    open var isPortReuseEnabled: Bool
    open private(set) var isStarted: Bool = false
    var queue: DispatchQueue
    var receiveHandler: OSCHandlerBlock?

    required public init(
        port: UInt16?,
        interface: String?,
        isPortReuseEnabled: Bool,
        timeTagMode: OSCTimeTagMode,
        queue: DispatchQueue?,
        receiveHandler: OSCHandlerBlock?
    ) {
        self.localPort = port ?? 0
        self.interface = interface
        self.isPortReuseEnabled = isPortReuseEnabled
        self.timeTagMode = timeTagMode
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

extension NoOpOSCUDPServer: @unchecked Sendable { } // TODO: unchecked
