# Receiving OSC

Receiving OSC messages and bundles.

## Overview

SwiftOSC offers a set of classes for both UDP and TCP network communication.

## UDP

Both ``OSCUDPServerProtocol`` and ``OSCUDPSocketProtocol`` are capable of receiving messages using the same API.

If not already set during initialization, you may set the receiver handler using the ``OSCUDPServerProtocol/setReceiveHandler(_:)`` or ``OSCUDPServerProtocol/setReceiveHandler(_:)`` method.

```swift
server.setReceiveHandler { [weak self] message, timeTag, host, port in
    self?.handle(message: message, host: host, port: port)
}

private func handle(message: OSCMessage, host: String, port: UInt16) {
    // handle received messages here
}
```

Then start the server/socket to begin listening for inbound OSC packets.

```swift
// call this once, usually during your app's startup
try server.start()
```

If received OSC bundles contain a future time tag and the `OSCUDPServer` is set to `.osc1_0` mode, these bundles will be held in memory automatically and scheduled to be dispatched to the handler at the future time.

Note that as per the OSC 1.1 proposal, this behavior has largely been deprecated. `OSCUDPServer` will default to `.ignore` and not perform any scheduling unless explicitly set to `.osc1_0` mode.

## TCP

Both ``OSCTCPClientProtocol`` and ``OSCTCPServerProtocol`` are capable of receiving messages using the same API.

If not already set during initialization, you may set the receiver handler using the ``OSCTCPClientProtocol/setReceiveHandler(_:)`` or ``OSCTCPServerProtocol/setReceiveHandler(_:)`` method.

```swift
server.setReceiveHandler { [weak self] message, timeTag, host, port in
    self?.handle(message: message, host: host, port: port)
}

private func handle(message: OSCMessage, host: String, port: UInt16) {
    // handle received messages here
}
```

For a client, connect to the remote host:

```swift
try client.connect()
```

For a server, bind to the local network port and begin listening for inbound connections:

```swift
try server.start()
```
