//
//  OSCTCPClientProtocol.swift
//  SwiftOSC Core • https://github.com/orchetect/swift-osc-core
//  © 2026 Steffan Andrews • Licensed under MIT License
//

import class Foundation.DispatchQueue
import typealias Foundation.TimeInterval
import SwiftOSCCore

/// Connects to a remote host via TCP connection in order to send and receive OSC packets over the network.
///
/// Use this class when a bidirectional TCP connection is desired to be made to a remote host.
///
/// A TCP connection is also generally more reliable than using the UDP protocol.
///
/// Since TCP is inherently a bidirectional network connection, both `OSCTCPClient` and `OSCTCPServer` can send and
/// receive once a connection is made. Messages sent by the server are only received by the client, and vice-versa.
///
/// What differentiates this client class from the server class is that the client class is designed to connect to a
/// remote TCP server. (Whereas, the server is designed to listen for inbound connections.)
public protocol OSCTCPClientProtocol: Sendable {
    /// Notification type.
    typealias Notification = OSCTCPClientNotification

    /// Notification handler closure.
    typealias NotificationHandlerBlock = @Sendable (_ notification: Notification) -> Void

    /// Initialize with a remote hostname and UDP port.
    ///
    /// > Note:
    /// >
    /// > Call ``connect(timeout:)`` to connect to the remote host in order to begin sending messages.
    /// > The connection may be closed at any time by calling ``close()`` and then reconnected again as needed.
    ///
    /// - Parameters:
    ///   - remoteHost: Remote hostname or IP address.
    ///   - remotePort: Remote port number.
    ///   - interface: Optionally specify a network interface for which to constrain connections.
    ///   - isIPv6Enabled: Enables IPv6 support. IPv4 support is always active.
    ///   - framingMode: TCP framing mode. Both server and client must use the same framing mode. (Default is recommended.)
    ///   - queue: Optionally supply a custom dispatch queue for receiving OSC packets and dispatching the
    ///     handler callback closure. If `nil`, a dedicated internal background queue will be used.
    ///   - receiveHandler: Handler to call when OSC packets are received.
    init(
        remoteHost: String,
        remotePort: UInt16,
        interface: String?,
        isIPv6Enabled: Bool,
        framingMode: OSCTCPFramingMode,
        queue: DispatchQueue?,
        receiveHandler: OSCPacketHandler?
    )

    // MARK: - Lifecycle

    /// Connects to the remote host.
    ///
    /// - Parameters:
    ///   - timeout: Supply a timeout period in seconds.
    func connect(timeout: TimeInterval) throws

    /// Close the connection, if any.
    func close()

    // MARK: - Communication

    /// Send an OSC bundle or message to the host.
    func send(_ packet: OSCPacket) throws

    /// Send an OSC bundle to the host.
    func send(_ bundle: OSCBundle) throws

    /// Send an OSC message to the host.
    func send(_ message: OSCMessage) throws

    // MARK: - Properties

    /// Local network host or IP address.
    /// The local address is resolved at the time of forming a connection to a remote server, when the local socket is bound.
    /// Returns `nil` when not connected.
    ///
    /// The local host address is determined by the ``interface`` (if specified), otherwise the appropriate
    /// default is used to communicate over all interfaces.
    var localHost: String? { get }

    /// Local network port.
    /// This port is automatically assigned by the system each time the client connects to a remote server.
    /// Returns `nil` when not connected.
    var localPort: UInt16? { get }

    /// Remote network host or IP address.
    var remoteHost: String { get }

    /// Remote network port.
    var remotePort: UInt16 { get }

    /// Network interface to restrict connections to.
    var interface: String? { get }

    /// Determines if IPv6 connectivity is enabled in addition to IPv4.
    /// If `false`, only IPv4 connectivity is enabled. (Default: disabled)
    /// This property must be set prior to calling ``connect(timeout:)``.
    var isIPv6Enabled: Bool { get set }

    /// Returns a boolean indicating whether the OSC socket is connected to the remote host.
    var isConnected: Bool { get }

    /// TCP packet framing mode.
    var framingMode: OSCTCPFramingMode { get }

    /// Set the receive handler closure.
    /// This closure will be called when OSC packets are received.
    func setReceiveHandler(_ handler: OSCPacketHandler?)

    /// Set the receive error handler closure.
    /// This closure will be called when receiving OSC packets that produce errors while decoding.
    func setReceiveErrorHandler(_ handler: OSCDecodeErrorHandlerBlock?)

    /// Set the notification handler closure.
    /// This closure will be called when a notification is generated, such as connection and disconnection events.
    func setNotificationHandler(_ handler: NotificationHandlerBlock?)
}

// MARK: - Defaulted Parameters

extension OSCTCPClientProtocol {
    /// Initialize with a remote hostname and UDP port.
    ///
    /// > Note:
    /// >
    /// > Call ``connect(timeout:)`` to connect to the remote host in order to begin sending messages.
    /// > The connection may be closed at any time by calling ``close()`` and then reconnected again as needed.
    ///
    /// - Parameters:
    ///   - remoteHost: Remote hostname or IP address.
    ///   - remotePort: Remote port number.
    ///   - interface: Optionally specify a network interface for which to constrain connections.
    ///   - isIPv6Enabled: Enables IPv6 support. IPv4 support is always active.
    ///   - framingMode: TCP framing mode. Both server and client must use the same framing mode. (Default is recommended.)
    ///   - queue: Optionally supply a custom dispatch queue for receiving OSC packets and dispatching the
    ///     handler callback closure. If `nil`, a dedicated internal background queue will be used.
    ///   - receiveHandler: Handler to call when OSC packets are received.
    @_disfavoredOverload
    public init(
        remoteHost: String,
        remotePort: UInt16,
        interface: String? = nil,
        isIPv6Enabled: Bool = false,
        framingMode: OSCTCPFramingMode = .osc1_1,
        queue: DispatchQueue? = nil,
        receiveHandler: OSCPacketHandler? = nil
    ) {
        self.init(
            remoteHost: remoteHost,
            remotePort: remotePort,
            interface: interface,
            isIPv6Enabled: isIPv6Enabled,
            framingMode: framingMode,
            queue: queue,
            receiveHandler: receiveHandler
        )
    }

    /// Connects to the remote host.
    ///
    /// - Parameters:
    ///   - timeout: Supply a timeout period in seconds.
    @_disfavoredOverload
    public func connect(timeout: TimeInterval = 5.0) throws {
        try connect(timeout: timeout)
    }
}

// MARK: - Default Implementation

extension OSCTCPClientProtocol {
    public func send(_ bundle: OSCBundle) throws {
        try send(.bundle(bundle))
    }

    public func send(_ message: OSCMessage) throws {
        try send(.message(message))
    }
}
