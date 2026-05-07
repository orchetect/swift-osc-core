//
//  OSCHandlerProtocol.swift
//  SwiftOSC I/O: SwiftNIO • https://github.com/orchetect/swift-osc-io-nio
//  © 2026 Steffan Andrews • Licensed under MIT License
//

import class Foundation.DispatchQueue
import struct Foundation.DispatchTime
import enum Foundation.DispatchTimeInterval
import typealias Foundation.TimeInterval

/// Internal protocol that TCP-based OSC classes adopt in order to handle incoming OSC data.
public protocol OSCHandlerProtocol: AnyObject where Self: Sendable {
    var queue: DispatchQueue { get }
    var timeTagMode: OSCTimeTagMode { get }
    var receiveHandler: OSCHandlerBlock? { get }
}

// MARK: - Handle and Dispatch

extension OSCHandlerProtocol {
    /// Handle incoming OSC data recursively.
    ///
    /// > Note:
    /// >
    /// > This method is called internally by OSC server and socket classes and is not needed to be called externally.
    public func handle(
        packet: OSCPacket,
        timeTag: OSCTimeTag = .immediate(),
        remoteHost: String,
        remotePort: UInt16
    ) {
        queue.async {
            switch packet {
            case let .bundle(bundle):
                for element in bundle.elements {
                    self.handle(
                        packet: element,
                        timeTag: bundle.timeTag,
                        remoteHost: remoteHost,
                        remotePort: remotePort
                    )
                }

            case let .message(message):
                self._schedule(
                    message,
                    at: timeTag,
                    remoteHost: remoteHost,
                    remotePort: remotePort
                )
            }
        }
    }

    private func _schedule(
        _ message: OSCMessage,
        at timeTag: OSCTimeTag = .immediate(),
        remoteHost: String,
        remotePort: UInt16
    ) {
        switch timeTagMode {
        case .ignore:
            _dispatch(message, timeTag: timeTag, remoteHost: remoteHost, remotePort: remotePort)

        case .osc1_0:
            // TimeTag of 1 has special meaning in OSC to dispatch "now".
            if timeTag.isImmediate {
                _dispatch(message, timeTag: timeTag, remoteHost: remoteHost, remotePort: remotePort)
                return
            }

            // If Time Tag is <= now, dispatch immediately.
            // Otherwise, schedule message for future dispatch.
            guard timeTag.isFuture else {
                _dispatch(message, timeTag: timeTag, remoteHost: remoteHost, remotePort: remotePort)
                return
            }

            let secondsFromNow = timeTag.timeIntervalSinceNow()
            _dispatch(
                message,
                timeTag: timeTag,
                remoteHost: remoteHost,
                remotePort: remotePort,
                at: secondsFromNow
            )
        }
    }

    private func _dispatch(
        _ message: OSCMessage,
        timeTag: OSCTimeTag,
        remoteHost: String,
        remotePort: UInt16
    ) {
        queue.async {
            self.receiveHandler?(message, timeTag, remoteHost, remotePort)
        }
    }

    private func _dispatch(
        _ message: OSCMessage,
        timeTag: OSCTimeTag,
        remoteHost: String,
        remotePort: UInt16,
        at secondsFromNow: TimeInterval
    ) {
        // clamp lower bound to 0
        guard secondsFromNow > 0 else {
            // don't schedule, just dispatch it immediately
            _dispatch(message, timeTag: timeTag, remoteHost: remoteHost, remotePort: remotePort)
            return
        }

        let usec = Int(secondsFromNow * TimeInterval(1_000_000))
        queue.asyncAfter(deadline: .now().advanced(by: .microseconds(usec))) { [weak self] in
            self?.receiveHandler?(message, timeTag, remoteHost, remotePort)
        }
    }
}
