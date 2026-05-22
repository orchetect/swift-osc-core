//
//  CIPUtils.swift
//  SwiftOSC Core • https://github.com/orchetect/swift-osc-core
//  © 2026 Steffan Andrews • Licensed under MIT License
//

#if canImport(Foundation)
import struct Foundation.Data
import class Foundation.NSArray
import class Foundation.NSMutableArray
#else
import struct FoundationEssentials.Data
import class FoundationEssentials.NSArray
import class FoundationEssentials.NSMutableArray
#endif

#if canImport(Darwin)
import Darwin
#elseif os(Linux) || os(Android)
#if canImport(Glibc)
@preconcurrency import Glibc
#elseif canImport(Musl)
@preconcurrency import Musl
#elseif canImport(Android)
@preconcurrency import Android
#endif
#elseif canImport(WASILibc)
@preconcurrency import WASILibc
#else
#error("SwiftOSC IO Internals was unable to identify the C library on the current platform.")
#endif

/// C IP address utilities.
enum CIPUtils {
    /// Internal:
    /// Queries the system and returns an array containing all the socket addresses (`sockaddr` as `Data`)
    /// for the given hostname or IP address.
    nonisolated
    static func sockaddrDataArray(forHostnameOrIPAddress host: String, port: UInt16) throws -> [Data] {
        var array: [Data] = []
        try sockaddrIterator(forHostnameOrIPAddress: host, port: port) { sockaddr, length in
            let sockaddrData = Data(bytes: sockaddr, count: length)
            array.append(sockaddrData)
            return true // continue iterator
        }
        return array
    }

    /// Internal:
    /// Queries the system and returns an array containing all the socket addresses (`sockaddr` as `Data`)
    /// for the given hostname or IP address.
    nonisolated
    static func sockaddrDataNSArray(forHostnameOrIPAddress host: String, port: UInt16) throws -> NSArray {
        let array: NSMutableArray = []
        try sockaddrIterator(forHostnameOrIPAddress: host, port: port) { sockaddr, length in
            let sockaddrData = Data(bytes: sockaddr, count: length)
            array.add(sockaddrData)
            return true // continue iterator
        }
        return array
    }

    /// Internal:
    /// Queries the system and returns an array containing all the socket addresses (`sockaddr`) for the given hostname or IP address.
    nonisolated
    static func sockaddrIterator(
        forHostnameOrIPAddress host: String,
        port: UInt16,
        _ block: (_ addr: UnsafeMutablePointer<sockaddr>, _ length: Int) throws -> Bool
    ) throws {
        // Ported from this Obj-C code:
        //
        // +(NSArray*)addressesForHost:(NSString*)host port:(NSNumber*)port error:(NSError**)outError
        // {
        //     struct addrinfo hints = {.ai_family=PF_UNSPEC;.ai_socktype=SOCK_STREAM;.ai_protocol=IPPROTO_TCP};
        //     struct addrinfo *res;
        //     int gai_error = getaddrinfo(host.UTF8String, port.stringValue.UTF8String, &hints, &res);
        //     if (gai_error) {
        //         if (outError) *outError = [
        //             NSError errorWithDomain:@"MyDomain"
        //             code:gai_error
        //             userInfo:@{NSLocalizedDescriptionKey:@(gai_strerror(gai_error))}
        //         ];
        //         return nil;
        //     }
        //     NSMutableArray *addresses = [NSMutableArray array];
        //     struct addrinfo *ai = res;
        //     do {
        //         NSData *address = [NSData dataWithBytes:ai->ai_addr length:ai->ai_addrlen];
        //         [addresses addObject:address];
        //     } while (ai = ai->ai_next);
        //     freeaddrinfo(res);
        //     return [addresses copy];
        // }

        let hintFamily = PF_UNSPEC

        #if os(Linux)
        let hintSockType = Int32(SOCK_STREAM.rawValue) // on Linux SOCK_STREAM is an enum, so we need to access its value
        #else
        let hintSockType = Int32(SOCK_STREAM) // re-casting to Int32 is needed for Android
        #endif

        let hintProtocol = Int32(IPPROTO_TCP) // re-casting to Int32 is needed for Linux/Android

        #if canImport(Darwin) || canImport(Android)
        // addrinfo on Darwin:
        // -------------------
        //     init(
        //         ai_flags: Int32,
        //         ai_family: Int32,
        //         ai_socktype: Int32,
        //         ai_protocol: Int32,
        //         ai_addrlen: socklen_t,
        //         ai_canonname: UnsafeMutablePointer<CChar>!,
        //         ai_addr: UnsafeMutablePointer<sockaddr>!,
        //         ai_next: UnsafeMutablePointer<addrinfo>!
        //     )
        var hints = addrinfo(
            ai_flags: 0,
            ai_family: hintFamily,
            ai_socktype: hintSockType,
            ai_protocol: hintProtocol,
            ai_addrlen: 0,
            ai_canonname: nil,
            ai_addr: nil,
            ai_next: nil
        )
        #elseif canImport(Glibc) || canImport(Musl) // addrinfo has different parameter order on Linux
        // addrinfo in Glibc:
        // ------------------
        //     struct addrinfo
        //     {
        //         int ai_flags;              /* Input flags. */
        //         int ai_family;             /* Protocol family for socket. */
        //         int ai_socktype;           /* Socket type. */
        //         int ai_protocol;           /* Protocol for socket. */
        //         socklen_t ai_addrlen;      /* Length of socket address. */
        //         struct sockaddr *ai_addr;  /* Socket address for socket. */
        //         char *ai_canonname;        /* Canonical name for service location. */
        //         struct addrinfo *ai_next;  /* Pointer to next in list. */
        //     };

        // addrinfo in Musl:
        // -----------------
        //     struct addrinfo {
        //         int ai_flags;
        //         int ai_family;
        //         int ai_socktype;
        //         int ai_protocol;
        //         socklen_t ai_addrlen;
        //         struct sockaddr *ai_addr;
        //         char *ai_canonname;
        //         struct addrinfo *ai_next;
        //     };
        var hints = addrinfo(
            ai_flags: 0,
            ai_family: hintFamily,
            ai_socktype: hintSockType,
            ai_protocol: hintProtocol,
            ai_addrlen: 0,
            ai_addr: nil,
            ai_canonname: nil,
            ai_next: nil
        )
        #elseif canImport(WASILibc)
        // TODO: add WASI support
        #endif

        let host = host.cString(using: .utf8)
        let port = String(port).cString(using: .utf8)
        var addr: UnsafeMutablePointer<addrinfo>?

        // func getaddrinfo(
        //     _: UnsafePointer<CChar>!, // host
        //     _: UnsafePointer<CChar>!, // port
        //     _: UnsafePointer<addrinfo>!, // hints
        //     _: UnsafeMutablePointer<UnsafeMutablePointer<addrinfo>?>! // inout addrinfo
        // ) -> Int32
        let result = getaddrinfo(host, port, &hints, &addr)

        if result != 0 {
            let errorDescription = String(cString: gai_strerror(result))
            throw IPUtils.ResolveError.error(code: Int(result), reason: errorDescription)
        }

        guard let addr else {
            throw IPUtils.ResolveError.error(reason: "Address pointer is nil.")
        }
        defer { freeaddrinfo(addr) }

        try addr.withMemoryRebound(to: addrinfo.self, capacity: 1) { pointer in
            var currentAddr: UnsafeMutablePointer<addrinfo>? = pointer
            while let a = currentAddr {
                let isShouldContinue = try block(a.pointee.ai_addr, Int(a.pointee.ai_addrlen))
                guard isShouldContinue else { return }
                currentAddr = a.pointee.ai_next
            }
        }
    }
}

extension CIPUtils {
    /// Internal:
    /// Returns the string value returned from the `sockaddr` for the given property.
    nonisolated
    static func string(for address: UnsafePointer<sockaddr>, length: Int, property: IPUtils.SocketAddressProperty) -> String? {
        var ipCString = [Int8](repeating: 0x00, count: Int(NI_MAXHOST))

        #if canImport(Darwin) || os(Linux)
        let ipCStringLength = socklen_t(ipCString.count) // socklen_t a.k.a UInt32
        #else
        let ipCStringLength = Int(ipCString.count)
        #endif

        let result = getnameinfo(
            address,
            socklen_t(length),
            &ipCString,
            ipCStringLength, // expects UInt32 on Darwin/Linux, but Int on Android
            nil,
            0,
            property.rawValue
        )
        guard result == 0 else { return nil }

        // decode C string
        guard let ipString = String(nullTerminatedCString: ipCString) else { return nil }
        return ipString
    }

    /// Internal:
    /// Returns the string value returned from the `sockaddr` data for the given property.
    nonisolated
    static func string(for sockaddrData: Data, property: IPUtils.SocketAddressProperty) -> String? {
        withUnsafePointer(ofSockaddrData: sockaddrData) { pointer in
            string(for: pointer, length: sockaddrData.count, property: property)
        }
    }

    /// Internal:
    /// Assumes data has the memory layout of a `sockaddr` instance and provides a scoped closure to access a typed pointer.
    nonisolated
    static func withUnsafePointer<T>(
        ofSockaddrData sockaddrData: Data,
        _ block: (_ pointer: UnsafePointer<sockaddr>) throws -> T?
    ) rethrows -> T? {
        try sockaddrData.withUnsafeBytes { pointer -> T? in
            guard let baseAddress = pointer.baseAddress else { return nil }
            let p = baseAddress.assumingMemoryBound(to: sockaddr.self)
            return try block(p)
        }
    }
}
