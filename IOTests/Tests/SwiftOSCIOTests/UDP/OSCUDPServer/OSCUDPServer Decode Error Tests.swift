//
//  OSCUDPServer Decode Error Tests.swift
//  SwiftOSC Core • https://github.com/orchetect/swift-osc-core
//  © 2026 Steffan Andrews • Licensed under MIT License
//

import Foundation
@testable import SwiftOSCIO
import Testing

extension SerializedTests {
    @Suite
    struct OSCUDPServer_Decode_Error_Tests {
        private actor Receiver {
            typealias ErrorPayload = (data: Data, error: OSCDecodeError, host: String, port: UInt16)
            var errors: [ErrorPayload] = []
            func addError(_ payload: ErrorPayload) { errors.append(payload) }
            init() { }
        }
        
        /// Test receiving non-OSC data (potentially totally unrelated packet types)
        @Test
        func receiveNonOSCData() async throws {
            let receiver = Receiver()
            
            // manually build a raw OSC message
            var nonOSCData: [UInt8] = []
            // address
            nonOSCData += "ABCDEFGH".data(using: .ascii)!
            
            let server = OSCUDPServer()
            
            try await confirmation("Receive Handler", expectedCount: 0) { receiveHandlerConfirmation in
                try await confirmation("Error Handler", expectedCount: 0) { errorHandlerConfirmation in
                    server.setReceiveHandler(.packets { packet, host, port in
                        guard !Task.isCancelled else { return }
                        receiveHandlerConfirmation()
                    })
                    
                    server.setReceiveErrorHandler { data, error, host, port in
                        guard !Task.isCancelled else { return }
                        errorHandlerConfirmation()
                        Task { await receiver.addError((data, error, host, port)) }
                    }
                    
                    // host and port here don't matter, as we're just feeding these messages into the server's internal receiver
                    server.core.dispatch(receivedPacket: nonOSCData, remoteHost: "dummy", remotePort: 8008)
                    
                    // allow a little time to wait for any asynchronous callbacks
                    try await Task.sleep(seconds: 0.5)
                }
            }
            
            #expect(await receiver.errors.isEmpty)
        }
        
        /// Test receiving OSC data with correct header bytes but malformed data within the packet.
        @Test
        func receiveMalformedData() async throws {
            let receiver = Receiver()
            
            // manually build a raw OSC message
            var malformedOSCData: [UInt8] = []
            // address
            malformedOSCData += [0x2F, 0x74, 0x65, 0x73,
                                 0x74, 0x61, 0x64, 0x64,
                                 0x72, 0x65, 0x73, 0x73, // "/testaddress"
                                 0x00, 0x00, 0x00, 0x00] // null null null null
                                                         // purposely omit value type tags, which results in a malformed packet
            
            let server = OSCUDPServer()
            
            await confirmation("Receive Handler", expectedCount: 0) { receiveHandlerConfirmation in
                await confirmation("Error Handler", expectedCount: 1) { errorHandlerConfirmation in
                    server.setReceiveHandler(.packets { packet, host, port in
                        guard !Task.isCancelled else { return }
                        receiveHandlerConfirmation()
                    })
                    
                    server.setReceiveErrorHandler { data, error, host, port in
                        guard !Task.isCancelled else { return }
                        errorHandlerConfirmation()
                        Task { await receiver.addError((data, error, host, port)) }
                    }
                    
                    // host and port here don't matter, as we're just feeding these messages into the server's internal receiver
                    server.core.dispatch(receivedPacket: malformedOSCData, remoteHost: "dummy", remotePort: 8008)
                    
                    await wait(expect: { await !receiver.errors.isEmpty }, timeout: 2.0)
                }
            }
            
            let payload = try await #require(receiver.errors.first)
            #expect(payload.data == Data(malformedOSCData))
            #expect(payload.host == "dummy")
            #expect(payload.port == 8008)
        }
    }
}
