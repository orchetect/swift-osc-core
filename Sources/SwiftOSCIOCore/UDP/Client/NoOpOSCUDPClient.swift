//
//  NoOpOSCUDPClient.swift
//  SwiftOSC Core • https://github.com/orchetect/swift-osc-core
//  © 2026 Steffan Andrews • Licensed under MIT License
//

import class Foundation.DispatchQueue

/// A no-op OSC UDP client implementation provided for testing, mocking, or as a stand-in on unsupported platforms.
open class NoOpOSCUDPClient: OSCUDPClientProtocol {
    open private(set) var localPort: UInt16
    open private(set) var interface: String?
    open var isPortReuseEnabled: Bool
    open var isIPv4BroadcastEnabled: Bool
    open private(set) var isStarted: Bool = false
    private var _isStartNeededToOperate: Bool
    
    public required convenience init() {
        self.init(
            localPort: nil,
            interface: nil,
            isPortReuseEnabled: false, // same as protocol defaults
            isIPv4BroadcastEnabled: false // same as protocol defaults
        )
        
        _isStartNeededToOperate = false
    }
    
    public required init(
        localPort: UInt16?,
        interface: String?,
        isPortReuseEnabled: Bool,
        isIPv4BroadcastEnabled: Bool
    ) {
        self.localPort = localPort ?? 0
        self.interface = interface
        self.isPortReuseEnabled = isPortReuseEnabled
        self.isIPv4BroadcastEnabled = isIPv4BroadcastEnabled

        _isStartNeededToOperate = true
    }
    
    // MARK: - Lifecycle
    
    open func start() throws {
        isStarted = true
    }
    
    open func stop() {
        isStarted = false
    }
    
    open func send(_ packet: OSCPacket, to host: String, port: UInt16) throws {
        if _isStartNeededToOperate, !isStarted {
            throw OSCIOError.notStarted
        }
        print("No-op send to \(host):\(port): \(packet)")
    }
}

extension NoOpOSCUDPClient: @unchecked Sendable { } // TODO: unchecked
