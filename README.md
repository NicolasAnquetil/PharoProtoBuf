# PharoProtoBuf

[Protocol Buffers](https://protobuf.dev) for [Pharo](https://pharo.org), written in pure Smalltalk.

**Status: early work in progress.** Only the wire-format layer (`Protobuf-Core`) exists so far.
It reads and writes every protobuf scalar encoding, so you can encode and decode messages by hand.
Message classes, schema handling and code generation from `.proto` files are planned.

## Installation

```smalltalk
Metacello new
	baseline: 'PharoProtoBuf';
	repository: 'github://NicolasAnquetil/PharoProtoBuf:main/src';
	load.
```

Developed on Pharo 14.

## Usage

Encode a message `{ string name = 1; int32 id = 2; }`:

```smalltalk
| writer |
writer := PBWireWriter new.
writer writeTag: 1 wireType: PBWireType len; writeString: 'Alice'.
writer writeTag: 2 wireType: PBWireType varint; writeInt32: 150.
writer contents.	"#[10 5 65 108 105 99 101 16 150 1]"
```

Decode it, skipping unknown fields:

```smalltalk
| reader tag name id |
reader := PBWireReader on: #[10 5 65 108 105 99 101 16 150 1].
[ reader atEnd ] whileFalse: [
	tag := reader readTag.
	tag fieldNumber = 1
		ifTrue: [ name := reader readString ]
		ifFalse: [
			tag fieldNumber = 2
				ifTrue: [ id := reader readInt32 ]
				ifFalse: [ reader skipField: tag ] ] ].
{ name. id }	"#('Alice' 150)"
```

Embedded messages and packed repeated fields use `writeLengthDelimited: [ :inner | ... ]` when writing,
and `readLengthDelimited` when reading. `readLengthDelimited` returns a sub-reader limited to that region.

## What `Protobuf-Core` provides

| Class | Role |
|---|---|
| `PBWireWriter` | Writes varints, int32/int64, uint32/uint64, sint32/sint64 (ZigZag), bool, enum, fixed32/64, sfixed32/64, float, double, bytes, strings (UTF-8), tags and nested length-delimited blocks |
| `PBWireReader` | Reads all of the above. `skipField:` skips unknown fields, including groups |
| `PBTag` | A decoded field key: field number and wire type |
| `PBWireType` | Wire type constants: `varint`, `i64`, `len`, `sgroup`, `egroup`, `i32` |
| `PBWireError` | Signaled for values out of range for their type, and for malformed input (truncated data, varints longer than 10 bytes, invalid tags, unclosed groups, invalid UTF-8) |

Encoding follows the [protobuf encoding spec](https://protobuf.dev/programming-guides/encoding/).
For example, a negative int32 takes 10 bytes on the wire, and int32 decoding keeps only the low 32 bits.

## Samples

`samples/` contains a binary `AddressBook` written by the official protobuf Java example
(`addressbook.proto`, from [protocolbuffers/protobuf](https://github.com/protocolbuffers/protobuf/tree/main/examples), BSD license).
`addressbook-sample.txt` is the same data decoded by `protoc --decode`, to compare against.
The people in it cover negative and extreme int32 ids, default values that are not written,
multi-byte UTF-8, strings longer than 127 bytes, all enum values, and nested messages.

## Roadmap

1. Message runtime: descriptors and a `PBMessage` base class with generic serialization
2. Reading `descriptor.proto`, then generating Pharo classes from `protoc --descriptor_set_out` output
3. oneof, maps, proto2 presence rules, merge semantics, unknown-field preservation
4. Optional: `.proto` parser, well-known types, JSON mapping, Connect/gRPC-Web over HTTP/1.1
