# OSC Value Types

OSC Message value types.

## Overview

The following OSC value types are available, conforming to the [Open Sound Control 1.0 specification](https://opensoundcontrol.stanford.edu/spec-1_0.html) and the [Open Sound Control 1.1 proposal](https://opensoundcontrol.stanford.edu/spec-1_1.html).

The _Syntax_ columns below provide easy reference for how to construct them.

### Core OSC Types

The following types are considered core (required) types by the OSC 1.0 specification.

| Type Tag | OSC Type                 | Swift Concrete Type | Standard Syntax | Convenience Syntax |
| -------- | ------------------------ | ------------------- | --------------- | ------------------ |
|   `i`    | int32 (big-endian)       | `Int32`             | `Int32(...)`    | -                  |
|   `f`    | float32 (big-endian)     | `Float32`           | `Float32(...)`  | -                  |
|   `s`    | string (null-terminated) | `String`            | `String(...)`   | `String` literal   |
|   `b`    | blob (null-terminated)   | `Data`              | `Data(...)`     | -                  |

The OSC 1.1 specification adds `T`, `F`, `N`, `I` and `t` to the core (required) list of types.

### Extended OSC Types

The following types are considered extended (optional) types by the OSC 1.0 specification.

The OSC 1.1 specification moves `T`, `F`, `N`, `I` and `t` from this list to the core (required) list of types.

| Type Tag | OSC Type                     | Swift Concrete Type   | Standard Syntax               | Convenience Syntax     |
| -------- | ---------------------------- | --------------------- | ----------------------------- | ---------------------- |
|  `T`/`F` | bool                         | `Bool`                | `true`, `false`               | -                      |
|    `h`   | int64 (big-endian)           | `Int64`               | `Int64(...)`                  | -                      |
|    `d`   | double (big-endian)          | `Double`              | `Double(...)`                 | -                      |
|    `c`   | ASCII character              | `Character`           | `Character(...)`              | `Character` literal    |
|  `[`/`]` | array                        | ``OSCArrayValue``     | `OSCArrayValue([...])`        | `.array([...])`        |
|    `t`   | time tag uint64 (big-endian) | ``OSCTimeTag``        | `OSCTimeTag(1)`               | `.timeTag(1)`          |
|    `S`   | alt string (null-terminated) | ``OSCStringAltValue`` | `OSCStringAltValue("String")` | `.stringAlt("String")` |
|    `m`   | 4-byte MIDI channel voice    | ``OSCMIDIValue``      | `OSCMIDIValue(...)`           | `.midi(...)`           |
|    `I`   | impulse/infinitum/bang       | ``OSCImpulseValue``   | `OSCImpulseValue()`           | `.impulse`             |
|    `N`   | null/nil                     | ``OSCNullValue``      | `OSCNullValue()`              | `.null`                |

Note that some organizations have defined their own extended sets of type tags, but they are not included in SwiftOSC as they are not officially included in any version of the formal OSC specification.

### Types Not Yet Implemented

- OSC Type Tag `r` (32-bit RGBA color)

### Interpolated OSC Types

SwiftOSC adds the following interpolated types. These types can be used directly and they will transparently encode and decode to compatible core OSC types on-the-fly. This is provided as a convenience and requires no extra handling.

| Type         | Encoding Type                                       |
| ------------ | --------------------------------------------------- |
| `Int`        | `Int32` (core type), converting any `BinaryInteger` |
| `Int8`       | `Int32` (core type)                                 |
| `Int16`      | `Int32` (core type)                                 |
| `UInt`       | `Int64` (core type)                                 |
| `UInt8`      | `Int32` (core type)                                 |
| `UInt16`     | `Int32` (core type)                                 |
| `UInt32`     | `Int64` (core type)                                 |
| `Float16`    | `Float32` (core type)                               |
| `Float80`    | `Double` (extended type)                            |
| `Substring`  | `String` (core type)                                |

### Type-Erased OSC Types

SwiftOSC also adds the following opaque type-erasure types.

| Type                  | Description                                          |
| --------------------- | ---------------------------------------------------- |
| ``AnyOSCNumberValue`` | Wraps any `BinaryInteger`, `BinaryFloatingPoint` or `Bool`. Used when masking OSC values to mask a type-erased number, and is not meant to be constructed directly. |

## Topics

- ``OSCValue``
- ``OSCValues``
- ``AnyOSCNumberValue``
- ``OSCArrayValue``
- ``OSCImpulseValue``
- ``OSCMIDIValue``
- ``OSCNullValue``
- ``OSCStringAltValue``
