# ``SwiftOSCIOCore/OSCTCPServerProtocol``

### Minimal Initialization

```swift 
let server = OSCTCPServer(
    port: 3032,
    receiveHandler: .messages { [weak self] message, timeTag, host, port in
        print("Received \(message) from client \(host):\(port)")
    }
)
```

### Advanced Initialization

```swift
let server = OSCTCPServer(
    port: 3032,
    interface: nil,
    isIPv6Enabled: false,
    framingMode: .osc1_1,
    queue: nil,
    receiveHandler: .messages { [weak self] message, timeTag, host, port in
        print("Received \(message) from client \(host):\(port)")
    }
)
```

### Setup

The receive handler may alternatively be provided after initialization if needed:

```swift
server.setReceiveHandler(.messages { [weak self] message, timeTag, host, port in
    print("Received \(message) from client \(host):\(port)")
})
```

Connection state notifications can be observed by providing a handler closure:

```swift
server.setNotificationHandler { [weak self] notification in
    switch notification {
        // ...
    }
}
```

Received OSC packet decode errors can be observed by providing a handler closure:

```swift
server.setReceiveErrorHandler { [weak self] data, error, host, port in
    // ...
}
```

Then in order to bind to the local network port and begin listening for inbound connections:

```swift
// call this once, usually during your app's startup
try server.start()
```

Inbound client connections are automatically accepted. One or more remote clients may be connected to a single
local server at the same time, each with their own independent bidirectional connection to the server.

OSC messages and bundles may be sent to all clients at once, or sent to individual clients discretely.

> Important:
>
> By default, SwiftOSC TCP classes use the OSC 1.1 SLIP packet framing mode.
> However, since there are two common framing modes used pervasively by hardware and software manufacturers,
> it is best practise to default to the latest (OSC 1.1 / SLIP) but provide the user the ability to select
> between the two in your application's user settings/preferences UI to maximize compatibility.

### Receiving OSC Messages

See <doc:Sending-OSC> and <doc:Receiving-OSC> for details on how to send and receive messages.
