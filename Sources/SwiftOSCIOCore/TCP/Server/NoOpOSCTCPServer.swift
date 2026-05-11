//
//  NoOpOSCTCPServer.swift
//  SwiftOSC Core • https://github.com/orchetect/swift-osc-core
//  © 2026 Steffan Andrews • Licensed under MIT License
//

import class Foundation.DispatchQueue

/// A no-op OSC TCP server implementation provided for testing, mocking, or as a stand-in on unsupported platforms.
open class NoOpOSCTCPServer: OSCTCPServerProtocol {
    open var timeTagMode: OSCTimeTagMode
    open private(set) var localPort: UInt16
    open private(set) var interface: String?
    open private(set) var isStarted: Bool = false
    open private(set) var framingMode: OSCTCPFramingMode
    open private(set) var clients: [OSCTCPClientSessionID: (host: String, port: UInt16)] = [:]
    var queue: DispatchQueue
    var receiveHandler: OSCHandlerBlock?
    var notificationHandler: NotificationHandlerBlock?
    
    required public init(
        port: UInt16?,
        interface: String?,
        timeTagMode: OSCTimeTagMode,
        framingMode: OSCTCPFramingMode,
        queue: DispatchQueue?,
        receiveHandler: OSCHandlerBlock?
    ) {
        self.localPort = port ?? 0
        self.interface = interface
        self.timeTagMode = timeTagMode
        self.framingMode = framingMode
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
    
    open func send(_ packet: OSCPacket, toClientID clientID: OSCTCPClientSessionID) throws {
        guard isStarted else { throw OSCTCPClientError.notStarted }
        print("No-op send to client ID \(clientID): \(packet)")
    }
    
    open func send(
        _ packet: OSCPacket,
        toClientIDs clientIDs: [OSCTCPClientSessionID]?,
        errorHandler: ((OSCTCPClientSessionID, any Error) -> Void)?
    ) {
        let clientIDs = clientIDs ?? Array(clients.keys)
        for clientID in clientIDs {
            do {
                try send(packet, toClientID: clientID)
            } catch {
                errorHandler?(clientID, error)
            }
        }
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

    open func disconnectClient(clientID: OSCTCPClientSessionID) {
        clients[clientID] = nil
    }
}

extension NoOpOSCTCPServer: @unchecked Sendable { } // TODO: unchecked
