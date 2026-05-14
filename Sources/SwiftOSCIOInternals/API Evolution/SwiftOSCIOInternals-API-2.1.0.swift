//
//  SwiftOSCIOInternals-API-2.1.0.swift
//  SwiftOSC Core • https://github.com/orchetect/swift-osc-core
//  © 2026 Steffan Andrews • Licensed under MIT License
//

import Foundation

@_documentation(visibility: internal)
@available(*, deprecated, renamed: "OSCTCPPacketDispatcherProtocol")
public typealias OSCTCPPacketHandlerProtocol = OSCTCPPacketDispatcherProtocol

extension OSCTCPPacketDispatcherProtocol {
    @_documentation(visibility: internal)
    @available(*, deprecated, renamed: "dispatch(receivedTCPFramedData:remoteHost:remotePort:)")
    public func handle(receivedData data: some DataProtocol, remoteHost: String, remotePort: UInt16) {
        dispatch(receivedTCPFramedData: data, remoteHost: remoteHost, remotePort: remotePort)
    }
}
