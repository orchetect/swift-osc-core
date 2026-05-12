# ``SwiftOSCIOCore/OSCTCPClientProtocol``

### Minimal Initialization

```swift
let client = OSCTCPClient(
    remoteHost: "192.168.1.20",
    remotePort: 3032
) { [weak self] message, timeTag, host, port in
    print("Received \(message) from server")
}
```

### Advanced Initialization

```swift
let client = OSCTCPClient(
    remoteHost: "192.168.1.20",
    remotePort: 3032,
    interface: nil,
    timeTagMode: .ignore,
    framingMode: .osc1_1,
    queue: nil
) { [weak self] message, timeTag, host, port in
    print("Received \(message) from server")
}
```

### Setup

Connection state notifications can be observed by providing a handler closure:

```swift
client.setNotificationHandler { [weak self] notification in
    switch notification {
        // ...
    }
}
```

Then in order to connect to the remote server:

```swift
try client.connect()
```

Once connected, messages may be sent and received bidirectionally between the client and server.

> Important:
>
> By default, SwiftOSC TCP classes use the OSC 1.1 SLIP packet framing mode.
> However, since there are two common framing modes used pervasively by hardware and software manufacturers,
> it is best practise to default to the latest (OSC 1.1 / SLIP) but provide the user the ability to select
> between the two in your application's user settings/preferences UI to maximize compatibility.

### Sending OSC Messages

See <doc:Sending-OSC> for details on how to send messages.
