//
//  String Extensions.swift
//  SwiftOSC Core • https://github.com/orchetect/swift-osc-core
//  © 2026 Steffan Andrews • Licensed under MIT License
//

extension String {
    /// Returns the address as individual path components (strings between `/` separators).
    package var oscAddressPathComponents: [Substring] {
        guard !isEmpty else { return [] }

        var addressSlice = self[startIndex...]

        if addressSlice.starts(with: "/") {
            addressSlice = addressSlice.dropFirst()
        }

        if addressSlice.hasSuffix("/") {
            addressSlice = addressSlice.dropLast()
        }

        if addressSlice.isEmpty { return [] }

        return addressSlice
            .split(
                separator: "/",
                omittingEmptySubsequences: false
            )
    }
}
