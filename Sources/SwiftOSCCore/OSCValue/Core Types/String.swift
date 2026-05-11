//
//  String.swift
//  SwiftOSC Core • https://github.com/orchetect/swift-osc-core
//  © 2026 Steffan Andrews • Licensed under MIT License
//

import Foundation

@_documentation(visibility: internal)
extension String: OSCValue {
    public static let oscValueToken: OSCValueToken = .string
}

@_documentation(visibility: internal)
extension String: OSCValueCodable {
    static let oscTag: Character = "s"
    public static let oscTagIdentity: OSCValueTagIdentity = .tag(oscTag)
}

@_documentation(visibility: internal)
extension String: OSCValueEncodable {
    public static let oscEncoding = OSCValueStaticTagEncoder<Self> { value throws(OSCEncodeError) in
        (
            tag: oscTag,
            // Encode as UTF-8 (a strict superset of ASCII). See
            // `OSCValueDecoder.readOSCNullTerminatedString()` for the matching decode path.
            data: OSCMessageEncoder.fourNullBytePadded(Data(value.utf8))
        )
    }
}

@_documentation(visibility: internal)
extension String: OSCValueDecodable {
    public static let oscDecoding = OSCValueStaticTagDecoder<Self> { decoder throws(OSCDecodeError) in
        try decoder.readOSCNullTerminatedString()
    }
}
