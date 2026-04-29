//
//  Float32.swift
//  SwiftOSC Core • https://github.com/orchetect/swift-osc-core
//  © 2026 Steffan Andrews • Licensed under MIT License
//

@_documentation(visibility: internal)
extension Float32: OSCValue {
    public static let oscValueToken: OSCValueToken = .float32
}

@_documentation(visibility: internal)
extension Float32: OSCValueCodable {
    static let oscTag: Character = "f"
    public static let oscTagIdentity: OSCValueTagIdentity = .tag(oscTag)
}

@_documentation(visibility: internal)
extension Float32: OSCValueEncodable {
    public static let oscEncoding = OSCValueStaticTagEncoder<Self> { value throws(OSCEncodeError) in
        (tag: oscTag, data: value.toData(.bigEndian))
    }
}

@_documentation(visibility: internal)
extension Float32: OSCValueDecodable {
    public static let oscDecoding = OSCValueStaticTagDecoder<Self> { decoder throws(OSCDecodeError) in
        try decoder.readOSCFloat32()
    }
}
