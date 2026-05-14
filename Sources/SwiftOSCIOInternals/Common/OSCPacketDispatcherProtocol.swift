//
//  OSCPacketDispatcherProtocol.swift
//  SwiftOSC Core • https://github.com/orchetect/swift-osc-core
//  © 2026 Steffan Andrews • Licensed under MIT License
//

import Foundation
import SwiftOSCIOCore

/// Internal protocol that OSC I/O classes adopt in order to handle incoming OSC packets.
public protocol OSCPacketDispatcherProtocol: AnyObject, OSCMessageDispatcherProtocol where Self: Sendable {
    var receiveHandler: OSCPacketHandler? { get }
    var receiveErrorHandler: OSCDecodeErrorHandlerBlock? { get }
}

// MARK: - Handle and Dispatch

extension OSCPacketDispatcherProtocol {
    /// Handle incoming OSC data using the ``receiveHandler``.
    ///
    /// > Note:
    /// >
    /// > This method is called internally by OSC server and socket classes and is not needed to be called externally.
    public func dispatch(
        packet: OSCPacket,
        remoteHost: String,
        remotePort: UInt16
    ) {
        guard let receiveHandler else { return }
        
        switch receiveHandler {
        case let .packets(handler):
            // dispatch immediately without unpacking bundles or scheduling - let consumer handle those tasks
            _dispatch(packet: packet, remoteHost: remoteHost, remotePort: remotePort, handler: handler)
            
        case let .messages(timeTagMode: timeTagMode, handler):
            // unpack into individual messages and schedule dispatch based on time-tag mode
            _dispatch(
                packet: packet,
                timeTag: nil,
                timeTagMode: timeTagMode,
                remoteHost: remoteHost,
                remotePort: remotePort,
                handler: handler
            )
        }
    }
    
    /// Internal: Dispatch an OSC packet immediately without unpacking bundles or scheduling.
    func _dispatch(
        packet: OSCPacket,
        remoteHost: String,
        remotePort: UInt16,
        handler: @escaping OSCPacketHandlerBlock
    ) {
        queue.async {
            handler(packet, remoteHost, remotePort)
        }
    }
    
    /// Internal: Unpack incoming OSC packets recursively and dispatch them to the scheduler.
    func _dispatch(
        packet: OSCPacket,
        timeTag: OSCTimeTag?,
        timeTagMode: OSCTimeTagMode,
        remoteHost: String,
        remotePort: UInt16,
        handler: @escaping OSCMessageHandlerBlock
    ) {
        queue.async {
            switch packet {
            case let .bundle(bundle):
                for element in bundle.elements {
                    self._dispatch(
                        packet: element,
                        timeTag: bundle.timeTag,
                        timeTagMode: timeTagMode,
                        remoteHost: remoteHost,
                        remotePort: remotePort,
                        handler: handler
                    )
                }

            case let .message(message):
                self.dispatch(
                    message,
                    timeTag: timeTag ?? .immediate(),
                    timeTagMode: timeTagMode,
                    remoteHost: remoteHost,
                    remotePort: remotePort,
                    handler: handler
                )
            }
        }
    }
}

// MARK: - Decoding Error Handling

extension OSCPacketDispatcherProtocol {
    /// Calls the error handler for received malformed OSC packets.
    ///
    /// > Note:
    /// >
    /// > This method is called internally by OSC server and socket classes and is not needed to be called externally.
    public func report(
        error: OSCDecodeError,
        forMalformedData data: Data,
        remoteHost: String,
        remotePort: UInt16
    ) {
        queue.async {
            self.receiveErrorHandler?(data, error, remoteHost, remotePort)
        }
    }
}
