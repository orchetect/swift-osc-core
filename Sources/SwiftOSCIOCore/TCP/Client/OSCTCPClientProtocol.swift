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
    ///   - timeTagMode: OSC TimeTag mode. (Default is recommended.)
    ///   - framingMode: TCP framing mode. Both server and client must use the same framing mode. (Default is recommended.)
    ///   - queue: Optionally supply a custom dispatch queue for receiving OSC packets and dispatching the
    ///     handler callback closure. If `nil`, a dedicated internal background queue will be used.
    ///   - receiveHandler: Handler to call when OSC bundles or messages are received.
    init(
        remoteHost: String,
        remotePort: UInt16,
        interface: String?,
        timeTagMode: OSCTimeTagMode,
        framingMode: OSCTCPFramingMode,
        queue: DispatchQueue?,
        receiveHandler: OSCHandlerBlock?
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
    
    /// Time tag mode. Determines how OSC bundle time tags are handled.
    var timeTagMode: OSCTimeTagMode { get set }
    
    /// Remote network hostname.
    var remoteHost: String { get }
    
    /// Remote network port.
    var remotePort: UInt16 { get }
    
    /// Network interface to restrict connections to.
    var interface: String? { get }
    
    /// Returns a boolean indicating whether the OSC socket is connected to the remote host.
    var isConnected: Bool { get }
    
    /// TCP packet framing mode.
    var framingMode: OSCTCPFramingMode { get }
    
    /// Set the receive handler closure.
    /// This closure will be called when OSC bundles or messages are received.
    func setReceiveHandler(_ handler: OSCHandlerBlock?)
    
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
    ///   - timeTagMode: OSC TimeTag mode. (Default is recommended.)
    ///   - framingMode: TCP framing mode. Both server and client must use the same framing mode. (Default is recommended.)
    ///   - queue: Optionally supply a custom dispatch queue for receiving OSC packets and dispatching the
    ///     handler callback closure. If `nil`, a dedicated internal background queue will be used.
    ///   - receiveHandler: Handler to call when OSC bundles or messages are received.
    @_disfavoredOverload
    public init(
        remoteHost: String,
        remotePort: UInt16,
        interface: String? = nil,
        timeTagMode: OSCTimeTagMode = .ignore,
        framingMode: OSCTCPFramingMode = .osc1_1,
        queue: DispatchQueue? = nil,
        receiveHandler: OSCHandlerBlock? = nil
    ) {
        self.init(
            remoteHost: remoteHost,
            remotePort: remotePort,
            interface: interface,
            timeTagMode: timeTagMode,
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
