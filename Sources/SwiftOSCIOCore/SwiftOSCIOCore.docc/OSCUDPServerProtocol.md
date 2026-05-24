# ``SwiftOSCIOCore/OSCUDPServerProtocol``

### Minimal Initialization

```swift
let server = OSCUDPServer(
    port: 8000,
    receiveHandler: .messages { [weak self] message, timeTag, host, port in
        print("Received \(message) from \(host):\(port)")
    }
)
```

### Advanced Initialization

```swift
let server = OSCUDPServer(
    port: 8000,
    interface: nil,
    isPortReuseEnabled: true,
    isIPv6Enabled: false,
    queue: nil,
    receiveHandler: .messages { [weak self] message, timeTag, host, port in
        print("Received \(message) from \(host):\(port)")
    }
)
```

### Setup

The receive handler may alternatively be provided after initialization if needed:

```swift
server.setReceiveHandler(.messages { [weak self] message, timeTag, host, port in
    print("Received \(message) from \(host):\(port)")
})
```

Received OSC packet decode errors can be observed by providing a handler closure:

```swift
server.setReceiveErrorHandler { [weak self] data, error, host, port in
    // ...
}
```

Ensure ``start()`` is called once after initialization in order to begin receiving messages.

```swift
try server.start()    
```

### Receiving OSC Messages

See <doc:Receiving-OSC> for details on how to receive messages.

### Notes

> OSC 1.0 Spec:
>
> With regards OSC Bundle Time Tag:
>
> An OSC server must have access to a representation of the correct current absolute time. OSC
> does not provide any mechanism for clock synchronization. If the time represented by the OSC
> Time Tag is before or equal to the current time, the OSC Server should invoke the methods
> immediately. Otherwise the OSC Time Tag represents a time in the future, and the OSC server
> must store the OSC Bundle until the specified time and then invoke the appropriate OSC
> Methods. When bundles contain other bundles, the OSC Time Tag of the enclosed bundle must be
> greater than or equal to the OSC Time Tag of the enclosing bundle.
