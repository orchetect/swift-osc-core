//
//  NoOpOSCTCPClient.swift
//  SwiftOSC Core • https://github.com/orchetect/swift-osc-core
//  © 2026 Steffan Andrews • Licensed under MIT License
//

import class Foundation.DispatchQueue
import typealias Foundation.TimeInterval

/// A no-op OSC TCP client implementation provided for testing, mocking, or as a stand-in on unsupported platforms.
open class NoOpOSCTCPClient: OSCTCPClientProtocol {
    open private(set) var localHost: String?
    open private(set) var localPort: UInt16?
    open private(set) var remoteHost: String
    open private(set) var remotePort: UInt16
    open private(set) var interface: String?
    open var isIPv6Enabled: Bool
    open private(set) var isConnected: Bool = false
    open private(set) var framingMode: OSCTCPFramingMode
    var queue: DispatchQueue
    var receiveHandler: OSCPacketHandler?
    var receiveErrorHandler: OSCDecodeErrorHandlerBlock?
    var notificationHandler: NotificationHandlerBlock?

    required public init(
        remoteHost: String,
        remotePort: UInt16,
        interface: String?,
        isIPv6Enabled: Bool,
        framingMode: OSCTCPFramingMode,
        queue: DispatchQueue?,
        receiveHandler: OSCPacketHandler?
    ) {
        self.remoteHost = remoteHost
        self.remotePort = remotePort
        self.interface = interface
        self.isIPv6Enabled = isIPv6Enabled
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
        guard isConnected else { throw OSCIOError.notConnected }
        print("No-op send: \(packet)")
    }

    // MARK: - Properties

    open func setReceiveHandler(_ handler: OSCPacketHandler?) {
        queue.sync {
            receiveHandler = handler
        }
    }

    open func setReceiveErrorHandler(_ handler: OSCDecodeErrorHandlerBlock?) {
        queue.sync {
            receiveErrorHandler = handler
        }
    }

    open func setNotificationHandler(_ handler: NotificationHandlerBlock?) {
        queue.sync {
            notificationHandler = handler
        }
    }
}

extension NoOpOSCTCPClient: @unchecked Sendable { } // TODO: unchecked
