//
//  OSCUDPServerProtocol.swift
//  SwiftOSC Core • https://github.com/orchetect/swift-osc-core
//  © 2026 Steffan Andrews • Licensed under MIT License
//

import class Foundation.DispatchQueue
import SwiftOSCCore

/// Receives OSC packets from the network on a specific UDP listen port.
///
/// A single global OSC server instance is often created once at app startup to receive OSC messages
/// on a specific local port. The default OSC port is 8000 but it may be set to any open port if
/// desired.
public protocol OSCUDPServerProtocol: Sendable {
    /// Initialize an OSC server.
    ///
    /// The default port for OSC communication is 8000 but may change depending on device/software
    /// manufacturer.
    ///
    /// > Note:
    /// >
    /// > Ensure ``start()`` is called once after initialization in order to begin receiving messages.
    ///
    /// - Parameters:
    ///   - port: Local port to listen on for inbound OSC packets.
    ///     If `nil` or `0`, a random available port in the system will be chosen.
    ///   - interface: Optionally specify a network interface for which to constrain communication.
    ///   - isPortReuseEnabled: Enable local UDP port reuse by other processes to receive broadcast packets.
    ///   - isIPv6Enabled: Enables IPv6 support. IPv4 support is always active.
    ///   - queue: Optionally supply a custom dispatch queue for receiving OSC packets and dispatching the
    ///     handler callback closure. If `nil`, a dedicated internal background queue will be used.
    ///   - receiveHandler: Handler to call when OSC packets are received.
    init(
        port: UInt16?,
        interface: String?,
        isPortReuseEnabled: Bool,
        isIPv6Enabled: Bool,
        queue: DispatchQueue?,
        receiveHandler: OSCPacketHandler?
    )

    // MARK: - Lifecycle

    /// Bind the local UDP port and begin listening for OSC packets.
    func start() throws

    /// Stops listening for data and closes the OSC server port.
    func stop()

    // MARK: - Properties

    /// Local network host or IP address.
    /// The local address is resolved at the time of starting the server, when the local socket is bound.
    /// Returns `nil` when not started.
    ///
    /// The local host address is determined by the ``interface`` (if specified), otherwise the appropriate
    /// default is used to communicate over all interfaces.
    var localHost: String? { get }

    /// UDP port used by the OSC server to listen for inbound OSC packets.
    /// This may only be set at the time of initialization.
    var localPort: UInt16 { get }

    /// Network interface to restrict connections to.
    var interface: String? { get }

    /// Enable local UDP port reuse by other processes.
    /// This property must be set prior to calling ``start()`` in order to take effect.
    ///
    /// By default, only one socket can be bound to a given IP address & port combination at a time. To enable
    /// multiple processes to simultaneously bind to the same address & port, you need to enable
    /// this functionality in the socket. All processes that wish to use the address & port
    /// simultaneously must all enable reuse port on the socket bound to that port.
    ///
    /// Due to limitations of `SO_REUSEPORT` on Apple platforms, enabling this only permits receipt of broadcast
    /// or multicast messages for any additional sockets which bind to the same address and port. Unicast
    /// messages are only received by the first socket to bind.
    var isPortReuseEnabled: Bool { get set }

    /// Determines if IPv6 connectivity is enabled in addition to IPv4.
    /// If `false`, only IPv4 connectivity is enabled. (Default: disabled)
    /// This property must be set prior to calling ``start()``.
    var isIPv6Enabled: Bool { get set }

    /// Returns a boolean indicating whether the OSC server has been started.
    var isStarted: Bool { get }

    /// Set the receive handler closure.
    /// This closure will be called when OSC packets are received.
    func setReceiveHandler(_ handler: OSCPacketHandler?)

    /// Set the receive error handler closure.
    /// This closure will be called when receiving OSC packets that produce errors while decoding.
    func setReceiveErrorHandler(_ handler: OSCDecodeErrorHandlerBlock?)
}

// MARK: - Defaulted Parameters

extension OSCUDPServerProtocol {
    /// Initialize an OSC server.
    ///
    /// The default port for OSC communication is 8000 but may change depending on device/software
    /// manufacturer.
    ///
    /// > Note:
    /// >
    /// > Ensure ``start()`` is called once after initialization in order to begin receiving messages.
    ///
    /// - Parameters:
    ///   - port: Local port to listen on for inbound OSC packets.
    ///     If `nil` or `0`, a random available port in the system will be chosen.
    ///   - interface: Optionally specify a network interface for which to constrain communication.
    ///   - isPortReuseEnabled: Enable local UDP port reuse by other processes to receive broadcast packets.
    ///   - isIPv6Enabled: Enables IPv6 support. IPv4 support is always active.
    ///   - queue: Optionally supply a custom dispatch queue for receiving OSC packets and dispatching the
    ///     handler callback closure. If `nil`, a dedicated internal background queue will be used.
    ///   - receiveHandler: Handler to call when OSC packets are received.
    @_disfavoredOverload
    public init(
        port: UInt16? = 8000,
        interface: String? = nil,
        isPortReuseEnabled: Bool = false,
        isIPv6Enabled: Bool = false,
        queue: DispatchQueue? = nil,
        receiveHandler: OSCPacketHandler? = nil
    ) {
        self.init(
            port: port,
            interface: interface,
            isPortReuseEnabled: isPortReuseEnabled,
            isIPv6Enabled: isIPv6Enabled,
            queue: queue,
            receiveHandler: receiveHandler
        )
    }
}
