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
    ///   - timeTagMode: OSC TimeTag mode. (Default is recommended.)
    ///   - queue: Optionally supply a custom dispatch queue for receiving OSC packets and dispatching the
    ///     handler callback closure. If `nil`, a dedicated internal background queue will be used.
    ///   - receiveHandler: Handler to call when OSC bundles or messages are received.
    init(
        port: UInt16?,
        interface: String?,
        isPortReuseEnabled: Bool,
        timeTagMode: OSCTimeTagMode,
        queue: DispatchQueue?,
        receiveHandler: OSCHandlerBlock?
    )
    
    // MARK: - Lifecycle
    
    /// Bind the local UDP port and begin listening for OSC packets.
    func start() throws
    
    /// Stops listening for data and closes the OSC server port.
    func stop()
    
    // MARK: - Properties
    
    /// Time tag mode. Determines how OSC bundle time tags are handled.
    var timeTagMode: OSCTimeTagMode { get set }
    
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
    
    /// Returns a boolean indicating whether the OSC server has been started.
    var isStarted: Bool { get }
    
    /// Set the receive handler closure.
    /// This closure will be called when OSC bundles or messages are received.
    func setReceiveHandler(_ handler: OSCHandlerBlock?)
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
    ///   - timeTagMode: OSC TimeTag mode. (Default is recommended.)
    ///   - queue: Optionally supply a custom dispatch queue for receiving OSC packets and dispatching the
    ///     handler callback closure. If `nil`, a dedicated internal background queue will be used.
    ///   - receiveHandler: Handler to call when OSC bundles or messages are received.
    @_disfavoredOverload
    public init(
        port: UInt16? = 8000,
        interface: String? = nil,
        isPortReuseEnabled: Bool = false,
        timeTagMode: OSCTimeTagMode = .ignore,
        queue: DispatchQueue? = nil,
        receiveHandler: OSCHandlerBlock? = nil
    ) {
        self.init(
            port: port,
            interface: interface,
            isPortReuseEnabled: isPortReuseEnabled,
            timeTagMode: timeTagMode,
            queue: queue,
            receiveHandler: receiveHandler
        )
    }
}
