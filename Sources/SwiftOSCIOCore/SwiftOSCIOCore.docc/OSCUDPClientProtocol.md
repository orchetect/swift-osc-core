# ``SwiftOSCIOCore/OSCUDPClientProtocol``

### Minimal Initialization

```swift
let client = OSCUDPClient()
```

This initializer **does not** require calling ``OSCUDPClientProtocol/start()`` before it may be used to send messages. 

### Advanced Initialization

```swift
let client = OSCUDPClient(
    localPort: 8000,
    interface: nil,
    isPortReuseEnabled: true,
    isIPv4BroadcastEnabled: true
)
```

Ensure ``OSCUDPClientProtocol/start()`` is called once after initialization in order to begin receiving messages.

```swift
try client.start()    
```

### Sending OSC Messages

See <doc:Sending-OSC> for details on how to send messages.
