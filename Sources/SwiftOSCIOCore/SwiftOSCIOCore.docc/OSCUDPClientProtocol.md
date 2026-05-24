# ``SwiftOSCIOCore/OSCUDPClientProtocol``

### Minimal Initialization

```swift
let client = OSCUDPClient()
``` 

### Advanced Initialization

```swift
let client = OSCUDPClient(
    localPort: 8000,
    interface: nil,
    isPortReuseEnabled: true,
    isIPv4BroadcastEnabled: true,
    isIPv6Enabled: false                    
)
```

### Setup

This class **does not** require calling ``OSCUDPClientProtocol/start()`` before it may be used to send messages, however you may choose to do so early in your app lifecycle when configuring network services in order to handle any local port binding errors proactively.

```swift
try client.start()    
```

### Sending OSC Messages

See <doc:Sending-OSC> for details on how to send messages.
