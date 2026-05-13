# ``SwiftOSCIOCore``

Network OSC I/O API protocols for SwiftOSCCore.

## Overview

![SwiftOSC Core](swift-osc-core-banner.png)

> Note:
>
> This module defines a common API layer for extension packages that implement network I/O. 
> This serves as common documentation applicable to all available I/O extension packages.

## I/O Protocols

- term ``OSCUDPClientProtocol``: Send OSC messages over UDP. (implemented as `OSCUDPClient` class)
- term ``OSCUDPServerProtocol``: Receive OSC messages over UDP. (implemented as `OSCUDPServer` class)
- term ``OSCUDPSocketProtocol``: Send and receive OSC messages over UDP using a single local port. (implemented as `OSCUDPSocket` class)
- term ``OSCTCPClientProtocol``: Connect to a remote host over TCP to send and receive OSC messages. (implemented as `OSCTCPClient` class)
- term ``OSCTCPServerProtocol``: Act as a TCP server to allow one or more remote clients to connect to send and receive OSC messages. (implemented as `OSCTCPServer` class)

## I/O Implementation

This package does not contain any actual networking I/O implementation.
Instead, individual network backends are available as extension repositories that each provide a full set of concrete implementations for the network I/O protocols defined by this package.

All I/O packages:
- provide concrete implementation using uniform target names and type names such that the I/O packages are interchangeable
- must pass the common I/O tests located in the SwiftOSCCore target

It is recommended to use only one I/O extension dependency exclusively in your project.

Alternatively, you are free to implement your own network sockets. You may choose to implement these protocols in order to take advantage of the free functionality and standard I/O test suite that accompany them.

## Value Types

- See [OSC Value Types](https://swiftpackageindex.com/orchetect/swift-osc-core/documentation/swiftosccore/osc-value-types) in the SwiftOSCCore package documentation.

## Sending and Receiving

- <doc:Sending-OSC>
- <doc:Receiving-OSC>
  - [OSC Address Pattern Parsing](https://swiftpackageindex.com/orchetect/swift-osc-core/documentation/swiftosccore/osc-address-pattern-parsing)
  - [OSC Value Parsing](https://swiftpackageindex.com/orchetect/swift-osc-core/documentation/swiftosccore/osc-value-parsing)

## Example Code

The [Examples](https://github.com/orchetect/swift-osc/tree/main/Examples) folder in the main SwiftOSC repository contains projects to quickly get started.

## Topics

### Introduction

- <doc:Sending-OSC>
- <doc:Receiving-OSC>

### Common

- ``OSCTimeTagMode``
- ``OSCHandlerBlock``
- ``OSCTCPFramingMode``
- ``OSCIOError``

### UDP Client

- ``OSCUDPClientProtocol``
- ``NoOpOSCUDPClient``

### UDP Server

- ``OSCUDPServerProtocol``
- ``NoOpOSCUDPServer``

### UDP Socket

- ``OSCUDPSocketProtocol``
- ``NoOpOSCUDPSocket``

### TCP Client

- ``OSCTCPClientProtocol``
- ``NoOpOSCTCPClient``

### TCP Server

- ``OSCTCPServerProtocol``
- ``OSCTCPServerNotification``
- ``OSCTCPClientSessionID``
- ``OSCTCPClientNotification``
- ``NoOpOSCTCPServer``

### TCP Frame Encoding

- ``TCPSLIPCoding``
- ``TCPSLIPDecodingError``
- ``TCPPacketLengthHeaderCoding``
- ``TCPPacketLengthHeaderDecodingError``
