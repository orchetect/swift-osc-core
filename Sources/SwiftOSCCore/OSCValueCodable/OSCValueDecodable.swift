//
//  OSCValueDecodable.swift
//  SwiftOSC Core • https://github.com/orchetect/swift-osc-core
//  © 2026 Steffan Andrews • Licensed under MIT License
//

/// Protocol requirements for ``OSCValue`` decoding.
public protocol OSCValueDecodable: SendableMetatype {
    associatedtype OSCDecoded: OSCValueDecodable
    associatedtype OSCValueDecodingBlock: OSCValueDecoderBlock
        where OSCValueDecodingBlock.OSCDecoded == OSCDecoded

    static var oscDecoding: OSCValueDecodingBlock { get }
}

// MARK: - Default Implementation

extension OSCValueDecodable {
    public typealias OSCDecoded = Self
}
