//
//  OSCDecodeErrorHandlerBlock.swift
//  SwiftOSC Core • https://github.com/orchetect/swift-osc-core
//  © 2026 Steffan Andrews • Licensed under MIT License
//

import struct Foundation.Data
import SwiftOSCCore

/// Received-message handler closure used by SwiftOSC I/O socket classes.
public typealias OSCDecodeErrorHandlerBlock = @Sendable (
    _ data: Data,
    _ error: OSCDecodeError,
    _ host: String,
    _ port: UInt16
) -> Void
