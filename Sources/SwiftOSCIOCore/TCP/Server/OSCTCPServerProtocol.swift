//
//  OSCTCPServerProtocol.swift
//  SwiftOSC Core • https://github.com/orchetect/swift-osc-core
//  © 2026 Steffan Andrews • Licensed under MIT License
//

import class Foundation.DispatchQueue
import SwiftOSCCore

/// Listens on a local port for TCP connections in order to send and receive OSC packets over the network.
///
/// Use this class when you are taking the role of the host and one or more remote clients will want to connect via
/// bidirectional TCP connection.
///
/// A TCP connection is also generally more reliable than using the UDP protocol.
///
/// Since TCP is inherently a bidirectional network connection, both `OSCTCPClient` and `OSCTCPServer` can send and
/// receive once a connection is made. Messages sent by the server are only received by the client, and vice-versa.
///
/// What differentiates this server class from the client class is that the server is designed to listen for inbound
/// connections. (Whereas, the client class is designed to connect to a remote TCP server.)
public protocol OSCTCPServerProtocol: Sendable {
    /// Notification type.
    typealias Notification = OSCTCPServerNotification

    /// Notification handler closure.
    typealias NotificationHandlerBlock = @Sendable (_ notification: Notification) -> Void

    /// Initialize with a remote hostname and UDP port.
    ///
    /// > Note:
    /// >
    /// > Call ``start()`` to begin listening for connections.
    /// > The connections may be closed at any time by calling ``stop()`` and then restarted again as needed.
    ///
    /// - Parameters:
    ///   - port: Local network port to listen for inbound connections.
    ///     If `nil` or `0`, a random available port in the system will be chosen.
    ///   - interface: Optionally specify a network interface for which to constrain connections.
    ///   - timeTagMode: OSC TimeTag mode. Default is recommended.
    ///   - framingMode: TCP framing mode. Both server and client must use the same framing mode. (Default is recommended.)
    ///   - queue: Optionally supply a custom dispatch queue for receiving OSC packets and dispatching the
    ///     handler callback closure. If `nil`, a dedicated internal background queue will be used.
    ///   - receiveHandler: Handler to call when OSC bundles or messages are received.
    init(
        port: UInt16?,
        interface: String?,
        timeTagMode: OSCTimeTagMode,
        framingMode: OSCTCPFramingMode,
        queue: DispatchQueue?,
        receiveHandler: OSCHandlerBlock?
    )

    // MARK: - Lifecycle

    /// Starts listening for inbound connections.
    func start() throws

    /// Closes any open client connections and stops listening for inbound connection requests.
    func stop()

    // MARK: - Communication

    /// Send an OSC bundle or message to an individual connected client.
    func send(_ packet: OSCPacket, toClientID clientID: OSCTCPClientSessionID) throws

    /// Send an OSC bundle to an individual connected client.
    func send(_ bundle: OSCBundle, toClientID clientID: OSCTCPClientSessionID) throws

    /// Send an OSC message to an individual connected client.
    func send(_ message: OSCMessage, toClientID clientID: OSCTCPClientSessionID) throws

    /// Send an OSC bundle or message to one or more connected clients.
    /// Passing `nil` client IDs (default) sends to all connected clients.
    /// Optionally supply an error handler that will be called for each error encountered.
    func send(
        _ packet: OSCPacket,
        toClientIDs clientIDs: [OSCTCPClientSessionID]?,
        errorHandler: ((_ clientID: OSCTCPClientSessionID, _ error: any Error) -> Void)?
    )

    /// Send an OSC bundle to one or more connected clients.
    /// Passing `nil` client IDs (default) sends to all connected clients.
    /// Optionally supply an error handler that will be called for each error encountered.
    func send(
        _ bundle: OSCBundle,
        toClientIDs clientIDs: [OSCTCPClientSessionID]?,
        errorHandler: ((_ clientID: OSCTCPClientSessionID, _ error: any Error) -> Void)?
    )

    /// Send an OSC message to one or more connected clients.
    /// Passing `nil` client IDs (default) sends to all connected clients.
    /// Optionally supply an error handler that will be called for each error encountered.
    func send(
        _ message: OSCMessage,
        toClientIDs clientIDs: [OSCTCPClientSessionID]?,
        errorHandler: ((_ clientID: OSCTCPClientSessionID, _ error: any Error) -> Void)?
    )

    // MARK: - Properties

    /// Time tag mode. Determines how OSC bundle time tags are handled.
    var timeTagMode: OSCTimeTagMode { get set }

    /// Local network port.
    var localPort: UInt16 { get }

    /// Network interface to restrict connections to.
    var interface: String? { get }

    /// Returns a boolean indicating whether the OSC server has been started.
    var isStarted: Bool { get }

    /// TCP packet framing mode.
    var framingMode: OSCTCPFramingMode { get }

    /// Returns a dictionary of currently connected clients keyed by client session ID.
    ///
    /// > Note:
    /// >
    /// > A client ID is transient and only valid for the lifecycle of the connection. Client IDs are randomly-assigned
    /// > upon each newly-made connection. For this reason, these IDs should not be stored persistently, but instead
    /// > queried from the OSC TCP server when a client connects or analyzing currently-connected clients.
    var clients: [OSCTCPClientSessionID: (host: String, port: UInt16)] { get }

    /// Set the receive handler closure.
    /// This closure will be called when OSC bundles or messages are received.
    func setReceiveHandler(_ handler: OSCHandlerBlock?)

    /// Set the notification handler closure.
    /// This closure will be called when a notification is generated, such as connection and disconnection events.
    func setNotificationHandler(_ handler: NotificationHandlerBlock?)

    /// Disconnect a connected client from the server.
    func disconnectClient(clientID: OSCTCPClientSessionID)
}

// MARK: - Defaulted Parameters

extension OSCTCPServerProtocol {
    /// Initialize with a remote hostname and UDP port.
    ///
    /// > Note:
    /// >
    /// > Call ``start()`` to begin listening for connections.
    /// > The connections may be closed at any time by calling ``stop()`` and then restarted again as needed.
    ///
    /// - Parameters:
    ///   - port: Local network port to listen for inbound connections.
    ///     If `nil` or `0`, a random available port in the system will be chosen.
    ///   - interface: Optionally specify a network interface for which to constrain connections.
    ///   - timeTagMode: OSC TimeTag mode. Default is recommended.
    ///   - framingMode: TCP framing mode. Both server and client must use the same framing mode. (Default is recommended.)
    ///   - queue: Optionally supply a custom dispatch queue for receiving OSC packets and dispatching the
    ///     handler callback closure. If `nil`, a dedicated internal background queue will be used.
    ///   - receiveHandler: Handler to call when OSC bundles or messages are received.
    @_disfavoredOverload
    public init(
        port: UInt16?,
        interface: String? = nil,
        timeTagMode: OSCTimeTagMode = .ignore,
        framingMode: OSCTCPFramingMode = .osc1_1,
        queue: DispatchQueue? = nil,
        receiveHandler: OSCHandlerBlock? = nil
    ) {
        self.init(
            port: port,
            interface: interface,
            timeTagMode: timeTagMode,
            framingMode: framingMode,
            queue: queue,
            receiveHandler: receiveHandler
        )
    }

    @_disfavoredOverload
    public func send(
        _ packet: OSCPacket,
        toClientIDs clientIDs: [OSCTCPClientSessionID]? = nil,
        errorHandler: ((_ clientID: OSCTCPClientSessionID, _ error: any Error) -> Void)? = nil
    ) {
        send(packet, toClientIDs: clientIDs, errorHandler: errorHandler)
    }
}

// MARK: - Default Implementation

extension OSCTCPServerProtocol {
    public func send(_ bundle: OSCBundle, toClientID clientID: OSCTCPClientSessionID) throws {
        try send(.bundle(bundle), toClientID: clientID)
    }

    public func send(_ message: OSCMessage, toClientID clientID: OSCTCPClientSessionID) throws {
        try send(.message(message), toClientID: clientID)
    }

    public func send(
        _ bundle: OSCBundle,
        toClientIDs clientIDs: [OSCTCPClientSessionID]? = nil,
        errorHandler: ((_ clientID: OSCTCPClientSessionID, _ error: any Error) -> Void)? = nil
    ) {
        send(.bundle(bundle), toClientIDs: clientIDs, errorHandler: errorHandler)
    }

    public func send(
        _ message: OSCMessage,
        toClientIDs clientIDs: [OSCTCPClientSessionID]? = nil,
        errorHandler: ((_ clientID: OSCTCPClientSessionID, _ error: any Error) -> Void)? = nil
    ) {
        send(.message(message), toClientIDs: clientIDs, errorHandler: errorHandler)
    }
}
