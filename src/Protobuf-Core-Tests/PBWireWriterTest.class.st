"
Tests PBWireWriter against byte sequences from the protobuf encoding specification.
"
Class {
	#name : 'PBWireWriterTest',
	#superclass : 'TestCase',
	#category : 'Protobuf-Core-Tests-Tests',
	#package : 'Protobuf-Core-Tests',
	#tag : 'Tests'
}

{ #category : 'helpers' }
PBWireWriterTest >> encode: aBlock [

	| writer |
	writer := PBWireWriter new.
	aBlock value: writer.
	^ writer contents
]

{ #category : 'tests - varint' }
PBWireWriterTest >> testWriteBoolAndEnum [

	self assert: (self encode: [ :w | w writeBool: true ]) equals: #[ 16r01 ].
	self assert: (self encode: [ :w | w writeBool: false ]) equals: #[ 16r00 ].
	self assert: (self encode: [ :w | w writeEnum: 2 ]) equals: #[ 16r02 ].
	self assert: (self encode: [ :w | w writeEnum: -1 ]) equals: #[ 16rFF 16rFF 16rFF 16rFF 16rFF 16rFF 16rFF 16rFF 16rFF 16r01 ]
]

{ #category : 'tests - length delimited' }
PBWireWriterTest >> testWriteBytesAndString [

	self assert: (self encode: [ :w | w writeString: 'testing' ]) equals: #[ 16r07 16r74 16r65 16r73 16r74 16r69 16r6E 16r67 ].
	self assert: (self encode: [ :w | w writeString: '' ]) equals: #[ 16r00 ].
	"U+00E9 is two UTF-8 bytes C3 A9; U+20AC is three bytes E2 82 AC"
	self
		assert: (self encode: [ :w | w writeString: (String with: (Character value: 16rE9) with: (Character value: 16r20AC)) ])
		equals: #[ 16r05 16rC3 16rA9 16rE2 16r82 16rAC ].
	self assert: (self encode: [ :w | w writeBytes: #[ 1 2 3 ] ]) equals: #[ 16r03 1 2 3 ].
	self assert: (self encode: [ :w | w writeBytes: (ByteArray new: 200) ]) size equals: 202
]

{ #category : 'tests - fixed' }
PBWireWriterTest >> testWriteFixed [

	self assert: (self encode: [ :w | w writeFixed32: 1 ]) equals: #[ 16r01 16r00 16r00 16r00 ].
	self assert: (self encode: [ :w | w writeFixed32: 16r12345678 ]) equals: #[ 16r78 16r56 16r34 16r12 ].
	self
		assert: (self encode: [ :w | w writeFixed64: 16r0102030405060708 ])
		equals: #[ 16r08 16r07 16r06 16r05 16r04 16r03 16r02 16r01 ].
	self assert: (self encode: [ :w | w writeSFixed32: -1 ]) equals: #[ 16rFF 16rFF 16rFF 16rFF ].
	self assert: (self encode: [ :w | w writeSFixed32: -2147483648 ]) equals: #[ 16r00 16r00 16r00 16r80 ].
	self assert: (self encode: [ :w | w writeSFixed64: -2 ]) equals: #[ 16rFE 16rFF 16rFF 16rFF 16rFF 16rFF 16rFF 16rFF ].
	self should: [ self encode: [ :w | w writeFixed32: 4294967296 ] ] raise: PBWireError.
	self should: [ self encode: [ :w | w writeFixed64: -1 ] ] raise: PBWireError.
	self should: [ self encode: [ :w | w writeSFixed32: 2147483648 ] ] raise: PBWireError.
	self should: [ self encode: [ :w | w writeSFixed64: 9223372036854775808 ] ] raise: PBWireError
]

{ #category : 'tests - fixed' }
PBWireWriterTest >> testWriteFloatAndDouble [

	self assert: (self encode: [ :w | w writeFloat: 1.0 ]) equals: #[ 16r00 16r00 16r80 16r3F ].
	self assert: (self encode: [ :w | w writeFloat: 0.1 ]) equals: #[ 16rCD 16rCC 16rCC 16r3D ].
	self assert: (self encode: [ :w | w writeFloat: Float negativeZero ]) equals: #[ 16r00 16r00 16r00 16r80 ].
	self assert: (self encode: [ :w | w writeFloat: Float infinity ]) equals: #[ 16r00 16r00 16r80 16r7F ].
	self assert: (self encode: [ :w | w writeDouble: 1.0 ]) equals: #[ 16r00 16r00 16r00 16r00 16r00 16r00 16rF0 16r3F ].
	self assert: (self encode: [ :w | w writeDouble: 0.1 ]) equals: #[ 16r9A 16r99 16r99 16r99 16r99 16r99 16rB9 16r3F ].
	self
		assert: (self encode: [ :w | w writeDouble: Float negativeZero ])
		equals: #[ 16r00 16r00 16r00 16r00 16r00 16r00 16r00 16r80 ].
	self
		assert: (self encode: [ :w | w writeDouble: Float negativeInfinity ])
		equals: #[ 16r00 16r00 16r00 16r00 16r00 16r00 16rF0 16rFF ].
	self assert: (self encode: [ :w | w writeDouble: 2 ]) equals: #[ 16r00 16r00 16r00 16r00 16r00 16r00 16r00 16r40 ]
]

{ #category : 'tests - varint' }
PBWireWriterTest >> testWriteInt32 [

	self assert: (self encode: [ :w | w writeInt32: 150 ]) equals: #[ 16r96 16r01 ].
	self assert: (self encode: [ :w | w writeInt32: 2147483647 ]) equals: #[ 16rFF 16rFF 16rFF 16rFF 16r07 ].
	self assert: (self encode: [ :w | w writeInt32: -1 ]) equals: #[ 16rFF 16rFF 16rFF 16rFF 16rFF 16rFF 16rFF 16rFF 16rFF 16r01 ].
	self
		assert: (self encode: [ :w | w writeInt32: -2147483648 ])
		equals: #[ 16r80 16r80 16r80 16r80 16rF8 16rFF 16rFF 16rFF 16rFF 16r01 ].
	self should: [ self encode: [ :w | w writeInt32: 2147483648 ] ] raise: PBWireError.
	self should: [ self encode: [ :w | w writeInt32: -2147483649 ] ] raise: PBWireError
]

{ #category : 'tests - varint' }
PBWireWriterTest >> testWriteInt64 [

	self
		assert: (self encode: [ :w | w writeInt64: 9223372036854775807 ])
		equals: #[ 16rFF 16rFF 16rFF 16rFF 16rFF 16rFF 16rFF 16rFF 16r7F ].
	self assert: (self encode: [ :w | w writeInt64: -1 ]) equals: #[ 16rFF 16rFF 16rFF 16rFF 16rFF 16rFF 16rFF 16rFF 16rFF 16r01 ].
	self
		assert: (self encode: [ :w | w writeInt64: -9223372036854775808 ])
		equals: #[ 16r80 16r80 16r80 16r80 16r80 16r80 16r80 16r80 16r80 16r01 ].
	self should: [ self encode: [ :w | w writeInt64: 9223372036854775808 ] ] raise: PBWireError.
	self should: [ self encode: [ :w | w writeInt64: -9223372036854775809 ] ] raise: PBWireError
]

{ #category : 'tests - length delimited' }
PBWireWriterTest >> testWriteLengthDelimited [
	"Spec: Test3 { Test1 c = 3 } with c.a = 150 -> 1a 03 08 96 01"

	self
		assert: (self encode: [ :w |
					 w writeTag: 3 wireType: PBWireType len.
					 w writeLengthDelimited: [ :inner |
							 inner writeTag: 1 wireType: PBWireType varint.
							 inner writeInt32: 150 ] ])
		equals: #[ 16r1A 16r03 16r08 16r96 16r01 ].
	"Spec: packed repeated int32 f = 4 with [3, 270, 86942] -> 22 06 03 8e 02 9e a7 05"
	self
		assert: (self encode: [ :w |
					 w writeTag: 4 wireType: PBWireType len.
					 w writeLengthDelimited: [ :inner | #( 3 270 86942 ) do: [ :each | inner writeInt32: each ] ] ])
		equals: #[ 16r22 16r06 16r03 16r8E 16r02 16r9E 16rA7 16r05 ]
]

{ #category : 'tests - varint' }
PBWireWriterTest >> testWriteSInt32 [
	"ZigZag table from the protobuf encoding spec."

	self assert: (self encode: [ :w | w writeSInt32: 0 ]) equals: #[ 16r00 ].
	self assert: (self encode: [ :w | w writeSInt32: -1 ]) equals: #[ 16r01 ].
	self assert: (self encode: [ :w | w writeSInt32: 1 ]) equals: #[ 16r02 ].
	self assert: (self encode: [ :w | w writeSInt32: -2 ]) equals: #[ 16r03 ].
	self assert: (self encode: [ :w | w writeSInt32: 2147483647 ]) equals: #[ 16rFE 16rFF 16rFF 16rFF 16r0F ].
	self assert: (self encode: [ :w | w writeSInt32: -2147483648 ]) equals: #[ 16rFF 16rFF 16rFF 16rFF 16r0F ].
	self should: [ self encode: [ :w | w writeSInt32: 2147483648 ] ] raise: PBWireError
]

{ #category : 'tests - varint' }
PBWireWriterTest >> testWriteSInt64 [

	self assert: (self encode: [ :w | w writeSInt64: -1 ]) equals: #[ 16r01 ].
	self
		assert: (self encode: [ :w | w writeSInt64: 9223372036854775807 ])
		equals: #[ 16rFE 16rFF 16rFF 16rFF 16rFF 16rFF 16rFF 16rFF 16rFF 16r01 ].
	self
		assert: (self encode: [ :w | w writeSInt64: -9223372036854775808 ])
		equals: #[ 16rFF 16rFF 16rFF 16rFF 16rFF 16rFF 16rFF 16rFF 16rFF 16r01 ].
	self should: [ self encode: [ :w | w writeSInt64: 9223372036854775808 ] ] raise: PBWireError
]

{ #category : 'tests - tag' }
PBWireWriterTest >> testWriteTag [

	self assert: (self encode: [ :w | w writeTag: 1 wireType: PBWireType varint ]) equals: #[ 16r08 ].
	self assert: (self encode: [ :w | w writeTag: 2 wireType: PBWireType len ]) equals: #[ 16r12 ].
	self assert: (self encode: [ :w | w writeTag: 1 wireType: PBWireType i64 ]) equals: #[ 16r09 ].
	self assert: (self encode: [ :w | w writeTag: 3 wireType: PBWireType i32 ]) equals: #[ 16r1D ].
	self assert: (self encode: [ :w | w writeTag: 4 wireType: PBWireType sgroup ]) equals: #[ 16r23 ].
	self assert: (self encode: [ :w | w writeTag: 4 wireType: PBWireType egroup ]) equals: #[ 16r24 ].
	self assert: (self encode: [ :w | w writeTag: 16 wireType: PBWireType varint ]) equals: #[ 16r80 16r01 ]
]

{ #category : 'tests - varint' }
PBWireWriterTest >> testWriteUInt32AndUInt64 [

	self assert: (self encode: [ :w | w writeUInt32: 4294967295 ]) equals: #[ 16rFF 16rFF 16rFF 16rFF 16r0F ].
	self
		assert: (self encode: [ :w | w writeUInt64: 18446744073709551615 ])
		equals: #[ 16rFF 16rFF 16rFF 16rFF 16rFF 16rFF 16rFF 16rFF 16rFF 16r01 ].
	self should: [ self encode: [ :w | w writeUInt32: -1 ] ] raise: PBWireError.
	self should: [ self encode: [ :w | w writeUInt32: 4294967296 ] ] raise: PBWireError.
	self should: [ self encode: [ :w | w writeUInt64: -1 ] ] raise: PBWireError.
	self should: [ self encode: [ :w | w writeUInt64: 18446744073709551616 ] ] raise: PBWireError
]

{ #category : 'tests - varint' }
PBWireWriterTest >> testWriteVarint [

	self assert: (self encode: [ :w | w writeVarint: 0 ]) equals: #[ 16r00 ].
	self assert: (self encode: [ :w | w writeVarint: 1 ]) equals: #[ 16r01 ].
	self assert: (self encode: [ :w | w writeVarint: 127 ]) equals: #[ 16r7F ].
	self assert: (self encode: [ :w | w writeVarint: 150 ]) equals: #[ 16r96 16r01 ].
	self assert: (self encode: [ :w | w writeVarint: 300 ]) equals: #[ 16rAC 16r02 ].
	self
		assert: (self encode: [ :w | w writeVarint: 18446744073709551615 ])
		equals: #[ 16rFF 16rFF 16rFF 16rFF 16rFF 16rFF 16rFF 16rFF 16rFF 16r01 ]
]
