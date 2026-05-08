//
//  NoOpOSCTCPClient.swift
//  SwiftOSC Core • https://github.com/orchetect/swift-osc-core
//  © 2026 Steffan Andrews • Licensed under MIT License
//

import class Foundation.DispatchQueue
import typealias Foundation.TimeInterval

/// A no-op OSC TCP client implementation provided for testing or mocking.
open class NoOpOSCTCPClient: OSCTCPClientProtocol {
    open var remoteHost: String
    open var remotePort: UInt16
    open var interface: String?
    open var timeTagMode: OSCTimeTagMode
    open internal(set) var isConnected: Bool = false
    open var framingMode: OSCTCPFramingMode
    var queue: DispatchQueue
    var receiveHandler: OSCHandlerBlock?
    var notificationHandler: NotificationHandlerBlock?

    required public init(
        remoteHost: String,
        remotePort: UInt16,
        interface: String?,
        timeTagMode: OSCTimeTagMode,
        framingMode: OSCTCPFramingMode,
        queue: DispatchQueue?,
        receiveHandler: OSCHandlerBlock?
    ) {
        self.remoteHost = remoteHost
        self.remotePort = remotePort
        self.interface = interface
        self.timeTagMode = timeTagMode
        self.framingMode = framingMode
        self.queue = queue ?? .global()
        self.receiveHandler = receiveHandler
    }

    // MARK: - Lifecycle

    open func connect(timeout: TimeInterval) throws {
        isConnected = true
    }

    open func close() {
        isConnected = false
    }

    // MARK: - Communication

    open func send(_ packet: OSCPacket) throws {
        guard isConnected else { throw OSCTCPClientError.notStarted }
        print("No-op send: \(packet)")
    }

    // MARK: - Properties

    open func setReceiveHandler(_ handler: OSCHandlerBlock?) {
        queue.sync {
            receiveHandler = handler
        }
    }

    open func setNotificationHandler(_ handler: NotificationHandlerBlock?) {
        queue.sync {
            notificationHandler = handler
        }
    }
}

extension NoOpOSCTCPClient: @unchecked Sendable { } // TODO: unchecked
