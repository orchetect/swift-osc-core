//
//  String Extensions.swift
//  SwiftOSC Core • https://github.com/orchetect/swift-osc-core
//  © 2026 Steffan Andrews • Licensed under MIT License
//

import Foundation

extension String {
    /// Internal:
    /// Converts a null-terminated C string to a `String`.
    @inlinable nonisolated
    init?(nullTerminatedCString cString: [Int8]) {
        guard let firstNullIndex = cString.firstIndex(of: 0x00) else { return nil }
        let charRange = Array(cString[cString.startIndex ... firstNullIndex])
        self.init(utf8String: charRange)
    }
}
