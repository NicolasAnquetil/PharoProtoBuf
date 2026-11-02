"
I encode protobuf wire-format primitives (varints, tags, fixed-width numbers, length-delimited data) into a ByteArray.
Values outside the range of their protobuf type raise PBWireError.

Example: encode a message { string name = 1; int32 id = 2; } with name = 'Alice' and id = 150:

	| writer |
	writer := PBWireWriter new.
	writer writeTag: 1 wireType: PBWireType len; writeString: 'Alice'.
	writer writeTag: 2 wireType: PBWireType varint; writeInt32: 150.
	writer contents.	""#[10 5 65 108 105 99 101 16 150 1]""

Embedded messages and packed repeated fields use writeLengthDelimited::

	writer writeTag: 3 wireType: PBWireType len.
	writer writeLengthDelimited: [ :inner | #(3 270 86942) do: [ :each | inner writeInt32: each ] ].

See PBWireReader for decoding.
"
Class {
	#name : 'PBWireWriter',
	#superclass : 'Object',
	#instVars : [
		'stream'
	],
	#category : 'Protobuf-Core',
	#package : 'Protobuf-Core'
}

{ #category : 'private' }
PBWireWriter >> check: anInteger between: min and: max [

	(anInteger isInteger and: [ anInteger between: min and: max ]) ifFalse: [
		PBWireError signal: anInteger printString , ' is outside [' , min printString , ', ' , max printString , ']' ]
]

{ #category : 'accessing' }
PBWireWriter >> contents [

	^ stream contents
]

{ #category : 'initialization' }
PBWireWriter >> initialize [

	super initialize.
	stream := WriteStream on: (ByteArray new: 64)
]

{ #category : 'writing - varint' }
PBWireWriter >> writeBool: aBoolean [

	stream nextPut: (aBoolean
			 ifTrue: [ 1 ]
			 ifFalse: [ 0 ])
]

{ #category : 'writing - length delimited' }
PBWireWriter >> writeBytes: aByteArray [

	self writeVarint: aByteArray size.
	stream nextPutAll: aByteArray
]

{ #category : 'writing - fixed' }
PBWireWriter >> writeDouble: aNumber [

	self writeLittleEndian: aNumber asFloat asIEEE64BitWord size: 8
]

{ #category : 'writing - varint' }
PBWireWriter >> writeEnum: anInteger [

	self writeInt32: anInteger
]

{ #category : 'writing - fixed' }
PBWireWriter >> writeFixed32: anInteger [

	self check: anInteger between: 0 and: 16rFFFFFFFF.
	self writeLittleEndian: anInteger size: 4
]

{ #category : 'writing - fixed' }
PBWireWriter >> writeFixed64: anInteger [

	self check: anInteger between: 0 and: 16rFFFFFFFFFFFFFFFF.
	self writeLittleEndian: anInteger size: 8
]

{ #category : 'writing - fixed' }
PBWireWriter >> writeFloat: aNumber [

	self writeLittleEndian: aNumber asFloat asIEEE32BitWord size: 4
]

{ #category : 'writing - varint' }
PBWireWriter >> writeInt32: anInteger [
	"Negative int32 values are sign-extended to 64 bits, hence 10 bytes on the wire."

	self check: anInteger between: -2147483648 and: 2147483647.
	self writeVarint: (anInteger bitAnd: 16rFFFFFFFFFFFFFFFF)
]

{ #category : 'writing - varint' }
PBWireWriter >> writeInt64: anInteger [

	self check: anInteger between: -9223372036854775808 and: 9223372036854775807.
	self writeVarint: (anInteger bitAnd: 16rFFFFFFFFFFFFFFFF)
]

{ #category : 'writing - length delimited' }
PBWireWriter >> writeLengthDelimited: aBlock [
	"Encode aBlock's output into a nested writer, then emit it length-prefixed."

	| inner |
	inner := self class new.
	aBlock value: inner.
	self writeBytes: inner contents
]

{ #category : 'private' }
PBWireWriter >> writeLittleEndian: anUnsignedInteger size: byteCount [

	1 to: byteCount do: [ :i | stream nextPut: (anUnsignedInteger byteAt: i) ]
]

{ #category : 'writing - raw' }
PBWireWriter >> writeRaw: aByteArray [
	"Copy already-encoded bytes (e.g. preserved unknown fields) as is."

	stream nextPutAll: aByteArray
]

{ #category : 'writing - fixed' }
PBWireWriter >> writeSFixed32: anInteger [

	self check: anInteger between: -2147483648 and: 2147483647.
	self writeLittleEndian: (anInteger bitAnd: 16rFFFFFFFF) size: 4
]

{ #category : 'writing - fixed' }
PBWireWriter >> writeSFixed64: anInteger [

	self check: anInteger between: -9223372036854775808 and: 9223372036854775807.
	self writeLittleEndian: (anInteger bitAnd: 16rFFFFFFFFFFFFFFFF) size: 8
]

{ #category : 'writing - varint' }
PBWireWriter >> writeSInt32: anInteger [

	self check: anInteger between: -2147483648 and: 2147483647.
	self writeVarint: (self zigZag: anInteger)
]

{ #category : 'writing - varint' }
PBWireWriter >> writeSInt64: anInteger [

	self check: anInteger between: -9223372036854775808 and: 9223372036854775807.
	self writeVarint: (self zigZag: anInteger)
]

{ #category : 'writing - length delimited' }
PBWireWriter >> writeString: aString [

	self writeBytes: aString utf8Encoded
]

{ #category : 'writing - tag' }
PBWireWriter >> writeTag: aFieldNumber wireType: aWireType [

	self writeVarint: ((aFieldNumber bitShift: 3) bitOr: aWireType)
]

{ #category : 'writing - varint' }
PBWireWriter >> writeUInt32: anInteger [

	self check: anInteger between: 0 and: 16rFFFFFFFF.
	self writeVarint: anInteger
]

{ #category : 'writing - varint' }
PBWireWriter >> writeUInt64: anInteger [

	self check: anInteger between: 0 and: 16rFFFFFFFFFFFFFFFF.
	self writeVarint: anInteger
]

{ #category : 'writing - varint' }
PBWireWriter >> writeVarint: anUnsignedInteger [
	"Base-128 little-endian groups, high bit set on all but the last byte."

	| value |
	value := anUnsignedInteger.
	[ value >= 16r80 ] whileTrue: [
			stream nextPut: ((value bitAnd: 16r7F) bitOr: 16r80).
			value := value bitShift: -7 ].
	stream nextPut: value
]

{ #category : 'private' }
PBWireWriter >> zigZag: anInteger [
	"Map signed to unsigned so small magnitudes stay small: 0,-1,1,-2 -> 0,1,2,3."

	^ anInteger >= 0
		  ifTrue: [ anInteger * 2 ]
		  ifFalse: [ anInteger negated * 2 - 1 ]
]
