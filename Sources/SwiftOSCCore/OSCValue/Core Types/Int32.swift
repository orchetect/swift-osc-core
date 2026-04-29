//
//  Int32.swift
//  SwiftOSC Core • https://github.com/orchetect/swift-osc-core
//  © 2026 Steffan Andrews • Licensed under MIT License
//

@_documentation(visibility: internal)
extension Int32: OSCValue {
    public static let oscValueToken: OSCValueToken = .int32
}

@_documentation(visibility: internal)
extension Int32: OSCValueCodable {
    static let oscTag: Character = "i"
    public static let oscTagIdentity: OSCValueTagIdentity = .tag(oscTag)
}

@_documentation(visibility: internal)
extension Int32: OSCValueEncodable {
    public static let oscEncoding = OSCValueStaticTagEncoder<Self> { value throws(OSCEncodeError) in
        (tag: oscTag, data: value.toData(.bigEndian))
    }
}

@_documentation(visibility: internal)
extension Int32: OSCValueDecodable {
    public static let oscDecoding = OSCValueStaticTagDecoder<Self> { decoder throws(OSCDecodeError) in
        try decoder.readOSCInt32()
    }
}
