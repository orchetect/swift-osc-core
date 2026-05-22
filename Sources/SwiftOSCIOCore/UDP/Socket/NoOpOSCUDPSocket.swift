//
//  NoOpOSCUDPSocket.swift
//  SwiftOSC Core • https://github.com/orchetect/swift-osc-core
//  © 2026 Steffan Andrews • Licensed under MIT License
//

import class Foundation.DispatchQueue

/// A no-op OSC UDP socket implementation provided for testing, mocking, or as a stand-in on unsupported platforms.
open class NoOpOSCUDPSocket: OSCUDPSocketProtocol {
    open var remoteHost: String?
    open private(set) var localPort: UInt16
    open var remotePort: UInt16 {
        didSet {
            if remotePort == 0 { remotePort = localPort }
        }
    }

    open private(set) var interface: String?
    open private(set) var isIPv4BroadcastEnabled: Bool
    open var isIPv6Enabled: Bool
    open private(set) var isStarted: Bool = false
    var queue: DispatchQueue
    var receiveHandler: OSCPacketHandler?
    var receiveErrorHandler: OSCDecodeErrorHandlerBlock?

    required public init(
        localPort: UInt16?,
        remoteHost: String?,
        remotePort: UInt16?,
        interface: String?,
        isIPv4BroadcastEnabled: Bool,
        isIPv6Enabled: Bool,
        queue: DispatchQueue?,
        receiveHandler: OSCPacketHandler?
    ) {
        self.localPort = localPort ?? 0
        self.remoteHost = remoteHost
        self.remotePort = remotePort ?? self.localPort
        self.interface = interface
        self.isIPv4BroadcastEnabled = isIPv4BroadcastEnabled
        self.isIPv6Enabled = isIPv6Enabled
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

    // MARK: - Communication

    open func send(_ packet: OSCPacket, to host: String?, port: UInt16?) throws {
        print("No-op send to \(host ?? "<unknown>"):\(port?.description ?? "<unknown>"): \(packet))")
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
}

extension NoOpOSCUDPSocket: @unchecked Sendable { } // TODO: unchecked
