//
//  BinaryInteger Extensions.swift
//  SwiftOSC Core • https://github.com/orchetect/swift-osc-core
//  © 2026 Steffan Andrews • Licensed under MIT License
//

extension BinaryInteger {
    /// Returns an integer as a hex string.
    /// Prefix optional.
    func hexString(prefix: Bool = true) -> String {
        (prefix ? "0x" : "")
            + String(self, radix: 16, uppercase: true)
    }
}
