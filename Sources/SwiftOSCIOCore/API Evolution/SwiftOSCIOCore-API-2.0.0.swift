//
//  SwiftOSCIOCore-API-2.0.0.swift
//  SwiftOSC Core • https://github.com/orchetect/swift-osc-core
//  © 2026 Steffan Andrews • Licensed under MIT License
//

import class Foundation.DispatchQueue

@_documentation(visibility: internal)
@available(*, deprecated, renamed: "OSCMessageHandlerBlock")
public typealias OSCHandlerBlock = OSCMessageHandlerBlock

extension OSCTCPClientProtocol {
    @_documentation(visibility: internal)
    @available(*, deprecated, message: "timeTagMode property has been removed and receiveHandler now takes a specialized handler case.")
    @_disfavoredOverload
    public init(
        remoteHost: String,
        remotePort: UInt16,
        interface: String? = nil,
        timeTagMode: OSCTimeTagMode = .ignore,
        framingMode: OSCTCPFramingMode = .osc1_1,
        queue: DispatchQueue? = nil,
        receiveHandler: OSCMessageHandlerBlock? = nil
    ) {
        let handler: OSCPacketHandler? = if let receiveHandler {
            .messages(timeTagMode: timeTagMode, receiveHandler)
        } else {
            nil
        }
        
        self.init(
            remoteHost: remoteHost,
            remotePort: remotePort,
            interface: interface,
            framingMode: framingMode,
            queue: queue,
            receiveHandler: handler
        )
    }
}

extension OSCTCPServerProtocol {
    @_documentation(visibility: internal)
    @available(*, deprecated, message: "timeTagMode property has been removed and receiveHandler now takes a specialized handler case.")
    @_disfavoredOverload
    public init(
        port: UInt16?,
        interface: String? = nil,
        timeTagMode: OSCTimeTagMode = .ignore,
        framingMode: OSCTCPFramingMode = .osc1_1,
        queue: DispatchQueue? = nil,
        receiveHandler: OSCMessageHandlerBlock? = nil
    ) {
        let handler: OSCPacketHandler? = if let receiveHandler {
            .messages(timeTagMode: timeTagMode, receiveHandler)
        } else {
            nil
        }
        
        self.init(
            port: port,
            interface: interface,
            framingMode: framingMode,
            queue: queue,
            receiveHandler: handler
        )
    }
}

extension OSCUDPServerProtocol {
    @_documentation(visibility: internal)
    @available(*, deprecated, message: "timeTagMode property has been removed and receiveHandler now takes a specialized handler case.")
    @_disfavoredOverload
    public init(
        port: UInt16? = 8000,
        interface: String? = nil,
        isPortReuseEnabled: Bool = false,
        timeTagMode: OSCTimeTagMode = .ignore,
        queue: DispatchQueue? = nil,
        receiveHandler: OSCMessageHandlerBlock? = nil
    ) {
        let handler: OSCPacketHandler? = if let receiveHandler {
            .messages(timeTagMode: timeTagMode, receiveHandler)
        } else {
            nil
        }
        
        self.init(
            port: port,
            interface: interface,
            isPortReuseEnabled: isPortReuseEnabled,
            queue: queue,
            receiveHandler: handler
        )
    }
}

extension OSCUDPSocketProtocol {
    @_documentation(visibility: internal)
    @available(*, deprecated, message: "timeTagMode property has been removed and receiveHandler now takes a specialized handler case.")
    @_disfavoredOverload
    public init(
        localPort: UInt16? = nil,
        remoteHost: String? = nil,
        remotePort: UInt16? = nil,
        interface: String? = nil,
        timeTagMode: OSCTimeTagMode = .ignore,
        isIPv4BroadcastEnabled: Bool = false,
        queue: DispatchQueue? = nil,
        receiveHandler: OSCMessageHandlerBlock? = nil
    ) {
        let handler: OSCPacketHandler? = if let receiveHandler {
            .messages(timeTagMode: timeTagMode, receiveHandler)
        } else {
            nil
        }
        
        self.init(
            localPort: localPort,
            remoteHost: remoteHost,
            remotePort: remotePort,
            interface: interface,
            isIPv4BroadcastEnabled: isIPv4BroadcastEnabled,
            queue: queue,
            receiveHandler: handler
        )
    }
}
