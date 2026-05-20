//
//  SwiftOSCIOInternalsTests.swift
//  SwiftOSC Core • https://github.com/orchetect/swift-osc-core
//  © 2026 Steffan Andrews • Licensed under MIT License
//

#if canImport(Foundation)
import Foundation
#endif

@testable import SwiftOSCIOInternals
import Testing

/// These tests assume that the hosts file on the local system contains both
/// IPv4 (`127.0.0.1`) and IPv6 (`::1`) IP addresses for the `localhost` hostname.
struct IPUtilsTests {
    struct ResolveTests {
        // MARK: - hostnames(forHostnameOrIPAddress:)
        
        @Test
        func hostnames() throws {
            #expect(try Set(IPUtils.hostnames(forHostnameOrIPAddress: "localhost")) == ["localhost"])
            #expect(try Set(IPUtils.hostnames(forHostnameOrIPAddress: "127.0.0.1")) == ["localhost"])
            #expect(try Set(IPUtils.hostnames(forHostnameOrIPAddress: "::1")) == ["localhost"])
            #expect(try Set(IPUtils.hostnames(forHostnameOrIPAddress: "::ffff:127.0.0.1")) == ["localhost"])
        }
        
        @Test
        func hostnames_edgeCases() throws {
            #expect(throws: (any Error).self) { _ = try IPUtils.hostnames(forHostnameOrIPAddress: "") }
            #expect(throws: (any Error).self) { _ = try IPUtils.hostnames(forHostnameOrIPAddress: " ") }
            #expect(throws: (any Error).self) { _ = try IPUtils.hostnames(forHostnameOrIPAddress: ".") }
            #expect(throws: (any Error).self) { _ = try IPUtils.hostnames(forHostnameOrIPAddress: "\(UUID())") }
        }
        
        // MARK: - ipAddresses(forHostnameOrIPAddress:families:)
        
        @Test
        func ipAddresses_localhost() throws {
            let host = "localhost"
            #expect(try Set(IPUtils.ipAddresses(forHostnameOrIPAddress: host, families: .all)) == [.v4("127.0.0.1"), .v6("::1")])
            #expect(try Set(IPUtils.ipAddresses(forHostnameOrIPAddress: host, families: [.ipv4])) == [.v4("127.0.0.1")])
            #expect(try Set(IPUtils.ipAddresses(forHostnameOrIPAddress: host, families: [.ipv6])) == [.v6("::1")])
        }
        
        @Test
        func ipAddresses_ipv4Loopback() throws {
            let host = "127.0.0.1"
            #expect(try Set(IPUtils.ipAddresses(forHostnameOrIPAddress: host, families: .all)) == [.v4("127.0.0.1")])
            #expect(try Set(IPUtils.ipAddresses(forHostnameOrIPAddress: host, families: [.ipv4])) == [.v4("127.0.0.1")])
            #expect(try Set(IPUtils.ipAddresses(forHostnameOrIPAddress: host, families: [.ipv6])) == [])
        }
        
        @Test
        func ipAddresses_ipv6Loopback() throws {
            let host = "::1"
            #expect(try Set(IPUtils.ipAddresses(forHostnameOrIPAddress: host, families: .all)) == [.v6("::1")])
            #expect(try Set(IPUtils.ipAddresses(forHostnameOrIPAddress: host, families: [.ipv4])) == [])
            #expect(try Set(IPUtils.ipAddresses(forHostnameOrIPAddress: host, families: [.ipv6])) == [.v6("::1")])
        }
        
        @Test
        func ipAddresses_ipv4MappedToIPv6Loopback() throws {
            let host = "::ffff:127.0.0.1"
            #expect(try Set(IPUtils.ipAddresses(forHostnameOrIPAddress: host, families: .all)) == [.v6("::ffff:127.0.0.1")])
            #expect(try Set(IPUtils.ipAddresses(forHostnameOrIPAddress: host, families: [.ipv4])) == [])
            #expect(try Set(IPUtils.ipAddresses(forHostnameOrIPAddress: host, families: [.ipv6])) == [.v6("::ffff:127.0.0.1")])
        }
        
        @Test
        func ipAddresses_edgeCases() throws {
            #expect(throws: (any Error).self) { _ = try IPUtils.ipAddresses(forHostnameOrIPAddress: "", families: .all) }
            #expect(throws: (any Error).self) { _ = try IPUtils.ipAddresses(forHostnameOrIPAddress: " ", families: .all) }
            #expect(throws: (any Error).self) { _ = try IPUtils.ipAddresses(forHostnameOrIPAddress: ".", families: .all) }
            #expect(throws: (any Error).self) { _ = try IPUtils.ipAddresses(forHostnameOrIPAddress: "\(UUID())", families: .all) }
        }

        // MARK: - ipAddress(forHostnameOrIPAddress:family:)

        @Test
        func ipAddress_localhost() throws {
            let host = "localhost"
            #expect(try IPUtils.ipAddress(forHostnameOrIPAddress: host, family: .ipv4) == "127.0.0.1")
            #expect(try IPUtils.ipAddress(forHostnameOrIPAddress: host, family: .ipv6) == "::1")
            #expect(try IPUtils.ipAddress(forHostnameOrIPAddress: host, family: .unix) == nil)
        }

        @Test
        func ipAddress_ipv4Loopback() throws {
            let host = "127.0.0.1"
            #expect(try IPUtils.ipAddress(forHostnameOrIPAddress: host, family: .ipv4) == "127.0.0.1")
            #expect(try IPUtils.ipAddress(forHostnameOrIPAddress: host, family: .ipv6) == nil)
            #expect(try IPUtils.ipAddress(forHostnameOrIPAddress: host, family: .unix) == nil)
        }

        @Test
        func ipAddress_ipv6Loopback() throws {
            let host = "::1"
            #expect(try IPUtils.ipAddress(forHostnameOrIPAddress: host, family: .ipv4) == nil)
            #expect(try IPUtils.ipAddress(forHostnameOrIPAddress: host, family: .ipv6) == "::1")
            #expect(try IPUtils.ipAddress(forHostnameOrIPAddress: host, family: .unix) == nil)
        }

        @Test
        func ipAddress_ipv4MappedToIPv6Loopback() throws {
            let host = "::ffff:127.0.0.1"
            #expect(try IPUtils.ipAddress(forHostnameOrIPAddress: host, family: .ipv4) == nil)
            #expect(try IPUtils.ipAddress(forHostnameOrIPAddress: host, family: .ipv6) == "::ffff:127.0.0.1")
            #expect(try IPUtils.ipAddress(forHostnameOrIPAddress: host, family: .unix) == nil)
        }
        
        @Test
        func ipAddress_edgeCases() throws {
            #expect(throws: (any Error).self) { _ = try IPUtils.ipAddress(forHostnameOrIPAddress: "", family: .ipv4) }
            #expect(throws: (any Error).self) { _ = try IPUtils.ipAddress(forHostnameOrIPAddress: " ", family: .ipv4) }
            #expect(throws: (any Error).self) { _ = try IPUtils.ipAddress(forHostnameOrIPAddress: ".", family: .ipv4) }
            #expect(throws: (any Error).self) { _ = try IPUtils.ipAddress(forHostnameOrIPAddress: "\(UUID())", family: .ipv4) }
        }

        // MARK: - ipAddressUsingReverseLookup(forHostnameOrIPAddress:family:)

        @Test
        func ipAddress_forHostnameOrIPAddress_localhost() throws {
            let host = "localhost"
            #expect(try IPUtils.ipAddressUsingReverseLookup(forHostnameOrIPAddress: host, family: .ipv4) == "127.0.0.1")
            #expect(try IPUtils.ipAddressUsingReverseLookup(forHostnameOrIPAddress: host, family: .ipv6) == "::1")
            #expect(try IPUtils.ipAddressUsingReverseLookup(forHostnameOrIPAddress: host, family: .unix) == nil)
        }

        @Test
        func ipAddress_forHostnameOrIPAddress_ipv4Loopback() throws {
            let host = "127.0.0.1"
            #expect(try IPUtils.ipAddressUsingReverseLookup(forHostnameOrIPAddress: host, family: .ipv4) == "127.0.0.1")
            #expect(try IPUtils.ipAddressUsingReverseLookup(forHostnameOrIPAddress: host, family: .ipv6) == "::1")
            #expect(try IPUtils.ipAddressUsingReverseLookup(forHostnameOrIPAddress: host, family: .unix) == nil)
        }

        @Test
        func ipAddress_forHostnameOrIPAddress_ipv6Loopback() throws {
            let host = "::1"
            #expect(try IPUtils.ipAddressUsingReverseLookup(forHostnameOrIPAddress: host, family: .ipv4) == "127.0.0.1")
            #expect(try IPUtils.ipAddressUsingReverseLookup(forHostnameOrIPAddress: host, family: .ipv6) == "::1")
            #expect(try IPUtils.ipAddressUsingReverseLookup(forHostnameOrIPAddress: host, family: .unix) == nil)
        }

        @Test
        func ipAddress_forHostnameOrIPAddress_ipv4MappedToIPv6Loopback() throws {
            let host = "::ffff:127.0.0.1"
            #expect(
                try IPUtils.ipAddressUsingReverseLookup(forHostnameOrIPAddress: host, forceHostnameLookup: false, family: .ipv4)
                    == "127.0.0.1"
            )
            #expect(
                try IPUtils.ipAddressUsingReverseLookup(forHostnameOrIPAddress: host, forceHostnameLookup: false, family: .ipv6)
                    == "::ffff:127.0.0.1"
            )
            #expect(
                try IPUtils.ipAddressUsingReverseLookup(forHostnameOrIPAddress: host, forceHostnameLookup: false, family: .unix)
                    == nil
            )
        }

        @Test
        func ipAddress_forHostnameOrIPAddress_ipv4MappedToIPv6Loopback_force() throws {
            let host = "::ffff:127.0.0.1"
            #expect(
                try IPUtils.ipAddressUsingReverseLookup(forHostnameOrIPAddress: host, forceHostnameLookup: true, family: .ipv4)
                    == "127.0.0.1"
            )
            #expect(
                try IPUtils.ipAddressUsingReverseLookup(forHostnameOrIPAddress: host, forceHostnameLookup: true, family: .ipv6)
                    == "::1"
            )
            #expect(
                try IPUtils.ipAddressUsingReverseLookup(forHostnameOrIPAddress: host, forceHostnameLookup: true, family: .unix)
                    == nil
            )
        }
    }

    struct ConcurrencyTests {
        @MainActor @Test
        func callFromMainActorCall() throws {
            _ = try IPUtils.ipAddresses(forHostnameOrIPAddress: "localhost", families: .all)
            _ = try IPUtils.ipAddress(forHostnameOrIPAddress: "localhost", family: .ipv4)
            _ = try IPUtils.hostnames(forHostnameOrIPAddress: "localhost")
        }

        @Test
        func callFromMainQueue() async {
            await withCheckedContinuation { continuation in
                DispatchQueue.main.async {
                    _ = try? IPUtils.ipAddresses(forHostnameOrIPAddress: "localhost", families: .all)
                    _ = try? IPUtils.ipAddress(forHostnameOrIPAddress: "localhost", family: .ipv4)
                    _ = try? IPUtils.hostnames(forHostnameOrIPAddress: "localhost")
                    continuation.resume()
                }
            }
        }

        @Test
        func callFromGlobalQueue() throws {
            try DispatchQueue.global().sync {
                _ = try IPUtils.ipAddresses(forHostnameOrIPAddress: "localhost", families: .all)
                _ = try IPUtils.ipAddress(forHostnameOrIPAddress: "localhost", family: .ipv4)
                _ = try IPUtils.hostnames(forHostnameOrIPAddress: "localhost")
            }
        }

        @Test
        func callFromTask() async throws {
            _ = try await Task {
                _ = try IPUtils.ipAddresses(forHostnameOrIPAddress: "localhost", families: .all)
                _ = try IPUtils.ipAddress(forHostnameOrIPAddress: "localhost", family: .ipv4)
                _ = try IPUtils.hostnames(forHostnameOrIPAddress: "localhost")
            }.value
        }

        @Test
        func manyConcurrentRequests_TaskGroup() async throws {
            try await withThrowingTaskGroup { group in
                for _ in 0 ..< 200 {
                    group.addTask {
                        _ = try IPUtils.ipAddress(forHostnameOrIPAddress: "localhost", family: .ipv4)
                    }
                }
                try await group.waitForAll()
            }
        }

        @Test
        func manyConcurrentRequests_DispatchGroup() {
            let group = DispatchGroup()
            for _ in 0 ..< 200 {
                group.enter()
                DispatchQueue.global().async {
                    _ = try? IPUtils.ipAddress(forHostnameOrIPAddress: "localhost", family: .ipv4)
                    group.leave()
                }
            }
            let result = group.wait(timeout: .now() + 10.0)
            #expect(result == .success)
        }
    }

    #if !GITHUB_ACTIONS
    @Test
    func performance() throws {
        // Baseline tests on an M1 Max MacBook Pro:
        // - Debug build with all sanitizers off, code coverage off, without Task: 1.335 sec (0.1335 ms per call)
        // - Debug build with all sanitizers off, code coverage off, with Task: 1.524 sec (0.1524 ms per call)
        // Ergo, adding the Task only adds a 14% performance overhead on average.

        // By contrast, SwiftNIO's `SocketAddress.makeAddressResolvingHost()` completes this in 1.041 sec (0.1041 ms per call)
        // However, that method does not let you specify address/protocol family; it only returns the first address found.

        for _ in 0 ..< 10000 {
            _ = try IPUtils.ipAddress(forHostnameOrIPAddress: "localhost", family: .ipv4)
        }
    }
    #endif
}
