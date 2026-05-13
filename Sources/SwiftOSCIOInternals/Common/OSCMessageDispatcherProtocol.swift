//
//  OSCMessageDispatcherProtocol.swift
//  SwiftOSC Core • https://github.com/orchetect/swift-osc-core
//  © 2026 Steffan Andrews • Licensed under MIT License
//

import Foundation
import SwiftOSCIOCore

/// Internal protocol that OSC I/O classes adopt in order to dispatch incoming OSC messages.
public protocol OSCMessageDispatcherProtocol: AnyObject where Self: Sendable {
    /// Dispatch queue for receiving OSC packets and dispatching the handler callback closure.
    var queue: DispatchQueue { get }
}

// MARK: - Handle and Dispatch

extension OSCMessageDispatcherProtocol {
    /// Schedule dispatch of incoming OSC messages.
    ///
    /// > Note:
    /// >
    /// > This method is called internally by OSC server and socket classes and is not needed to be called externally.
    public func dispatch(
        _ message: OSCMessage,
        timeTag: OSCTimeTag,
        timeTagMode: OSCTimeTagMode,
        remoteHost: String,
        remotePort: UInt16,
        handler: @escaping OSCMessageHandlerBlock
    ) {
        switch timeTagMode {
        case .ignore:
            _dispatch(message, timeTag: timeTag, remoteHost: remoteHost, remotePort: remotePort, handler: handler)

        case .osc1_0:
            // TimeTag of 1 has special meaning in OSC to dispatch "now".
            if timeTag.isImmediate {
                _dispatch(message, timeTag: timeTag, remoteHost: remoteHost, remotePort: remotePort, handler: handler)
                return
            }

            // If Time Tag is <= now, dispatch immediately.
            // Otherwise, schedule message for future dispatch.
            guard timeTag.isFuture else {
                _dispatch(message, timeTag: timeTag, remoteHost: remoteHost, remotePort: remotePort, handler: handler)
                return
            }

            let secondsFromNow = timeTag.timeIntervalSinceNow()
            _dispatch(
                message,
                timeTag: timeTag,
                remoteHost: remoteHost,
                remotePort: remotePort,
                at: secondsFromNow,
                handler: handler
            )
        }
    }

    private func _dispatch(
        _ message: OSCMessage,
        timeTag: OSCTimeTag,
        remoteHost: String,
        remotePort: UInt16,
        handler: @escaping OSCMessageHandlerBlock
    ) {
        queue.async {
            handler(message, timeTag, remoteHost, remotePort)
        }
    }

    private func _dispatch(
        _ message: OSCMessage,
        timeTag: OSCTimeTag,
        remoteHost: String,
        remotePort: UInt16,
        at secondsFromNow: TimeInterval,
        handler: @escaping OSCMessageHandlerBlock
    ) {
        // clamp lower bound to 0
        guard secondsFromNow > 0 else {
            // don't schedule, just dispatch it immediately
            _dispatch(message, timeTag: timeTag, remoteHost: remoteHost, remotePort: remotePort, handler: handler)
            return
        }

        queue.asyncAfter(deadline: .now() + secondsFromNow) {
            handler(message, timeTag, remoteHost, remotePort)
        }
    }
}
