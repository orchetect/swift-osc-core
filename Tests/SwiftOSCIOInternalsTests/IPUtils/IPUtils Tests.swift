//
//  SwiftOSCIOInternalsTests.swift
//  SwiftOSC Core • https://github.com/orchetect/swift-osc-core
//  © 2026 Steffan Andrews • Licensed under MIT License
//

#if canImport(FoundationEssentials)
import struct FoundationEssentials.UUID
import class Foundation.DispatchQueue
#else
import struct Foundation.UUID
import class Foundation.DispatchQueue
#endif

@testable import SwiftOSCIOInternals
import Testing

/// These tests assume that the hosts file on the local system contains both
/// IPv4 (`127.0.0.1`) and IPv6 (`::1`) IP addresses for the `localhost` hostname.
@Suite
struct IPUtilsTests {
    @Suite
    struct ResolveTests {
        // MARK: - hostnames(forHostnameOrIPAddress:)
        
        @Test
        func hostnames() {
            #expect(Set(IPUtils.hostnames(forHostnameOrIPAddress: "localhost")) == ["localhost"])
            #expect(Set(IPUtils.hostnames(forHostnameOrIPAddress: "127.0.0.1")) == ["localhost"])
            #expect(Set(IPUtils.hostnames(forHostnameOrIPAddress: "::1")) == ["localhost"])
        }

        @Test
        func hostnames_edgeCases() {
            #expect(Set(IPUtils.hostnames(forHostnameOrIPAddress: "")) == [])
            #expect(Set(IPUtils.hostnames(forHostnameOrIPAddress: " ")) == [])
            #expect(Set(IPUtils.hostnames(forHostnameOrIPAddress: ".")) == [])
            #expect(Set(IPUtils.hostnames(forHostnameOrIPAddress: UUID().uuidString)) == [])
        }

        // MARK: - ipAddresses(forHostnameOrIPAddress:families:)
        
        @Test
        func ipAddresses_localhost() async {
            #expect(Set(IPUtils.ipAddresses(forHostnameOrIPAddress: "localhost", families: .all)) == [.v4("127.0.0.1"), .v6("::1")])
            #expect(Set(IPUtils.ipAddresses(forHostnameOrIPAddress: "localhost", families: [.ipv4])) == [.v4("127.0.0.1")])
            #expect(Set(IPUtils.ipAddresses(forHostnameOrIPAddress: "localhost", families: [.ipv6])) == [.v6("::1")])
        }
        
        @Test
        func ipAddresses_127_0_0_1() {
            #expect(Set(IPUtils.ipAddresses(forHostnameOrIPAddress: "127.0.0.1", families: .all)) == [.v4("127.0.0.1")])
            #expect(Set(IPUtils.ipAddresses(forHostnameOrIPAddress: "127.0.0.1", families: [.ipv4])) == [.v4("127.0.0.1")])
            #expect(Set(IPUtils.ipAddresses(forHostnameOrIPAddress: "127.0.0.1", families: [.ipv6])) == [])
        }
        
        @Test
        func ipAddresses_colon_colon_1() {
            #expect(Set(IPUtils.ipAddresses(forHostnameOrIPAddress: "::1", families: .all)) == [.v6("::1")])
            #expect(Set(IPUtils.ipAddresses(forHostnameOrIPAddress: "::1", families: [.ipv4])) == [])
            #expect(Set(IPUtils.ipAddresses(forHostnameOrIPAddress: "::1", families: [.ipv6])) == [.v6("::1")])
        }
        
        @Test
        func ipAddresses_edgeCases() {
            #expect(Set(IPUtils.ipAddresses(forHostnameOrIPAddress: "", families: .all)) == [])
            #expect(Set(IPUtils.ipAddresses(forHostnameOrIPAddress: " ", families: .all)) == [])
            #expect(Set(IPUtils.ipAddresses(forHostnameOrIPAddress: ".", families: .all)) == [])
            #expect(Set(IPUtils.ipAddresses(forHostnameOrIPAddress: UUID().uuidString, families: .all)) == [])
        }
        
        // MARK: - ipAddress(forHostnameOrIPAddress:family:)
        
        @Test
        func ipAddress_localhost() {
            #expect(IPUtils.ipAddress(forHostnameOrIPAddress: "localhost", family: .ipv4) == "127.0.0.1")
            #expect(IPUtils.ipAddress(forHostnameOrIPAddress: "localhost", family: .ipv6) == "::1")
            #expect(IPUtils.ipAddress(forHostnameOrIPAddress: "localhost", family: .unix) == nil)
        }
        
        @Test
        func ipAddress_127_0_0_1() {
            #expect(IPUtils.ipAddress(forHostnameOrIPAddress: "127.0.0.1", family: .ipv4) == "127.0.0.1")
            #expect(IPUtils.ipAddress(forHostnameOrIPAddress: "127.0.0.1", family: .ipv6) == nil)
            #expect(IPUtils.ipAddress(forHostnameOrIPAddress: "127.0.0.1", family: .unix) == nil)
        }
        
        @Test
        func ipAddress_colon_colon_1() {
            #expect(IPUtils.ipAddress(forHostnameOrIPAddress: "::1", family: .ipv4) == nil)
            #expect(IPUtils.ipAddress(forHostnameOrIPAddress: "::1", family: .ipv6) == "::1")
            #expect(IPUtils.ipAddress(forHostnameOrIPAddress: "::1", family: .unix) == nil)
        }
        
        // MARK: - ipAddressUsingReverseLookup(forHostnameOrIPAddress:family:)
        
        @Test
        func ipAddress_forHostnameOrIPAddress_localhost() {
            #expect(IPUtils.ipAddressUsingReverseLookup(forHostnameOrIPAddress: "localhost", family: .ipv4) == "127.0.0.1")
            #expect(IPUtils.ipAddressUsingReverseLookup(forHostnameOrIPAddress: "localhost", family: .ipv6) == "::1")
            #expect(IPUtils.ipAddressUsingReverseLookup(forHostnameOrIPAddress: "localhost", family: .unix) == nil)
        }
        
        @Test
        func ipAddress_forHostnameOrIPAddress_127_0_0_1() {
            #expect(IPUtils.ipAddressUsingReverseLookup(forHostnameOrIPAddress: "127.0.0.1", family: .ipv4) == "127.0.0.1")
            #expect(IPUtils.ipAddressUsingReverseLookup(forHostnameOrIPAddress: "127.0.0.1", family: .ipv6) == "::1")
            #expect(IPUtils.ipAddressUsingReverseLookup(forHostnameOrIPAddress: "127.0.0.1", family: .unix) == nil)
        }
        
        @Test
        func ipAddress_forHostnameOrIPAddress_colon_colon_1() {
            #expect(IPUtils.ipAddressUsingReverseLookup(forHostnameOrIPAddress: "::1", family: .ipv4) == "127.0.0.1")
            #expect(IPUtils.ipAddressUsingReverseLookup(forHostnameOrIPAddress: "::1", family: .ipv6) == "::1")
            #expect(IPUtils.ipAddressUsingReverseLookup(forHostnameOrIPAddress: "::1", family: .unix) == nil)
        }
    }
    
    @Suite
    struct ConcurrencyTests {
        @MainActor @Test
        func callFromMainActorCall() {
            #expect(Set(IPUtils.ipAddresses(forHostnameOrIPAddress: "localhost", families: .all)) == [.v4("127.0.0.1"), .v6("::1")])
            #expect(IPUtils.ipAddress(forHostnameOrIPAddress: "localhost", family: .ipv4) == "127.0.0.1")
            #expect(Set(IPUtils.hostnames(forHostnameOrIPAddress: "localhost")) == ["localhost"])
        }
        
        @Test
        func callFromMainQueue() async {
            await withCheckedContinuation { continuation in
                DispatchQueue.main.async {
                    #expect(Set(IPUtils.ipAddresses(forHostnameOrIPAddress: "localhost", families: .all)) == [.v4("127.0.0.1"), .v6("::1")])
                    #expect(IPUtils.ipAddress(forHostnameOrIPAddress: "localhost", family: .ipv4) == "127.0.0.1")
                    #expect(Set(IPUtils.hostnames(forHostnameOrIPAddress: "localhost")) == ["localhost"])
                    continuation.resume()
                }
            }
        }
        
        @Test
        func callFromGlobalQueue() {
            DispatchQueue.global().sync {
                #expect(Set(IPUtils.ipAddresses(forHostnameOrIPAddress: "localhost", families: .all)) == [.v4("127.0.0.1"), .v6("::1")])
                #expect(IPUtils.ipAddress(forHostnameOrIPAddress: "localhost", family: .ipv4) == "127.0.0.1")
                #expect(Set(IPUtils.hostnames(forHostnameOrIPAddress: "localhost")) == ["localhost"])
            }
        }
        
        @Test
        func callFromTask() async {
            _ = await Task {
                #expect(Set(IPUtils.ipAddresses(forHostnameOrIPAddress: "localhost", families: .all)) == [.v4("127.0.0.1"), .v6("::1")])
                #expect(IPUtils.ipAddress(forHostnameOrIPAddress: "localhost", family: .ipv4) == "127.0.0.1")
                #expect(Set(IPUtils.hostnames(forHostnameOrIPAddress: "localhost")) == ["localhost"])
            }.value
        }
    }
    
    #if !GITHUB_ACTIONS
    @Test
    func performance() {
        // Baseline tests on an M1 Max MacBook Pro:
        // - Debug build with all sanitizers off, code coverage off, without Task: 1.335 sec (0.1335 ms per call)
        // - Debug build with all sanitizers off, code coverage off, with Task: 1.524 sec (0.1524 ms per call)
        // Ergo, adding the Task only adds a 14% performance overhead on average.

        // By contrast, SwiftNIO's `SocketAddress.makeAddressResolvingHost()` completes this in 1.041 sec (0.1041 ms per call)
        // However, that method does not let you specify address/protocol family; it only returns the first address found.

        for _ in 0 ..< 10_000 {
            _ = IPUtils.ipAddress(forHostnameOrIPAddress: "localhost", family: .ipv4)
        }
    }
    #endif
}
