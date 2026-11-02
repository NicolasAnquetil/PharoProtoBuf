"
Tests PBWireReader decoding of byte sequences from the protobuf encoding specification, and its error handling.
"
Class {
	#name : 'PBWireReaderTest',
	#superclass : 'TestCase',
	#category : 'Protobuf-Core-Tests-Tests',
	#package : 'Protobuf-Core-Tests',
	#tag : 'Tests'
}

{ #category : 'tests - skip' }
PBWireReaderTest >> assertSkipping: aByteArray landsOnFieldTwo: aString [
	"aByteArray holds one field, followed by 10 05 (field 2 = 5)."

	| reader |
	reader := PBWireReader on: aByteArray , #[ 16r10 16r05 ].
	reader skipField: reader readTag.
	self assert: reader readTag fieldNumber = 2 description: 'skipping ' , aString.
	self assert: reader readVarint equals: 5.
	self assert: reader atEnd
]

{ #category : 'tests - errors' }
PBWireReaderTest >> testMalformedInput [
	"Truncated varint"

	self should: [ (PBWireReader on: #[ 16r96 ]) readVarint ] raise: PBWireError.
	self should: [ (PBWireReader on: #[  ]) readVarint ] raise: PBWireError.
	"Varint longer than 10 bytes"
	self
		should: [ (PBWireReader on: #[ 16r80 16r80 16r80 16r80 16r80 16r80 16r80 16r80 16r80 16r80 16r01 ]) readVarint ]
		raise: PBWireError.
	"Truncated fixed-width"
	self should: [ (PBWireReader on: #[ 1 2 3 ]) readFixed32 ] raise: PBWireError.
	self should: [ (PBWireReader on: #[ 1 2 3 4 5 6 7 ]) readDouble ] raise: PBWireError.
	"Length prefix beyond the end"
	self should: [ (PBWireReader on: #[ 16r05 1 2 ]) readBytes ] raise: PBWireError.
	self should: [ (PBWireReader on: #[ 16r05 1 2 ]) readLengthDelimited ] raise: PBWireError.
	"Invalid UTF-8"
	self should: [ (PBWireReader on: #[ 16r02 16rC3 16r28 ]) readString ] raise: PBWireError
]

{ #category : 'tests - length delimited' }
PBWireReaderTest >> testReadBytesAndString [

	| reader |
	self assert: (PBWireReader on: #[ 16r07 16r74 16r65 16r73 16r74 16r69 16r6E 16r67 ]) readString equals: 'testing'.
	self assert: (PBWireReader on: #[ 16r00 ]) readString equals: ''.
	self
		assert: (PBWireReader on: #[ 16r05 16rC3 16rA9 16rE2 16r82 16rAC ]) readString
		equals: (String with: (Character value: 16rE9) with: (Character value: 16r20AC)).
	reader := PBWireReader on: #[ 16r03 1 2 3 16r2A ].
	self assert: reader readBytes equals: #[ 1 2 3 ].
	self assert: reader readVarint equals: 42.
	self assert: reader atEnd
]

{ #category : 'tests - fixed' }
PBWireReaderTest >> testReadFixed [

	self assert: (PBWireReader on: #[ 16r78 16r56 16r34 16r12 ]) readFixed32 equals: 16r12345678.
	self assert: (PBWireReader on: #[ 16rFF 16rFF 16rFF 16rFF ]) readFixed32 equals: 4294967295.
	self assert: (PBWireReader on: #[ 16r08 16r07 16r06 16r05 16r04 16r03 16r02 16r01 ]) readFixed64 equals: 16r0102030405060708.
	self assert: (PBWireReader on: #[ 16rFF 16rFF 16rFF 16rFF ]) readSFixed32 equals: -1.
	self assert: (PBWireReader on: #[ 16r00 16r00 16r00 16r80 ]) readSFixed32 equals: -2147483648.
	self assert: (PBWireReader on: #[ 16rFE 16rFF 16rFF 16rFF 16rFF 16rFF 16rFF 16rFF ]) readSFixed64 equals: -2
]

{ #category : 'tests - fixed' }
PBWireReaderTest >> testReadFloatAndDouble [

	| negZero |
	self assert: (PBWireReader on: #[ 16r00 16r00 16r80 16r3F ]) readFloat equals: 1.0.
	self assert: (PBWireReader on: #[ 16rCD 16rCC 16rCC 16r3D ]) readFloat equals: (Float fromIEEE32Bit: 16r3DCCCCCD).
	self assert: (PBWireReader on: #[ 16r00 16r00 16r80 16r7F ]) readFloat equals: Float infinity.
	self assert: (PBWireReader on: #[ 16r00 16r00 16rC0 16r7F ]) readFloat isNaN.
	negZero := (PBWireReader on: #[ 16r00 16r00 16r00 16r80 ]) readFloat.
	self assert: negZero equals: 0.0.
	self assert: negZero signBit equals: 1.
	self assert: (PBWireReader on: #[ 16r9A 16r99 16r99 16r99 16r99 16r99 16rB9 16r3F ]) readDouble equals: 0.1.
	self assert: (PBWireReader on: #[ 16r00 16r00 16r00 16r00 16r00 16r00 16rF0 16rFF ]) readDouble equals: Float negativeInfinity.
	self assert: (PBWireReader on: #[ 16r00 16r00 16r00 16r00 16r00 16r00 16rF8 16r7F ]) readDouble isNaN.
	negZero := (PBWireReader on: #[ 16r00 16r00 16r00 16r00 16r00 16r00 16r00 16r80 ]) readDouble.
	self assert: negZero equals: 0.0.
	self assert: negZero signBit equals: 1
]

{ #category : 'tests - varint' }
PBWireReaderTest >> testReadInt32AndInt64 [

	self assert: (PBWireReader on: #[ 16r96 16r01 ]) readInt32 equals: 150.
	self assert: (PBWireReader on: #[ 16rFF 16rFF 16rFF 16rFF 16rFF 16rFF 16rFF 16rFF 16rFF 16r01 ]) readInt32 equals: -1.
	self assert: (PBWireReader on: #[ 16r80 16r80 16r80 16r80 16rF8 16rFF 16rFF 16rFF 16rFF 16r01 ]) readInt32 equals: -2147483648.
	"Compact 5-byte negative int32 (accepted by other implementations)"
	self assert: (PBWireReader on: #[ 16rFF 16rFF 16rFF 16rFF 16r0F ]) readInt32 equals: -1.
	self assert: (PBWireReader on: #[ 16rFF 16rFF 16rFF 16rFF 16rFF 16rFF 16rFF 16rFF 16rFF 16r01 ]) readInt64 equals: -1.
	self assert: (PBWireReader on: #[ 16rFF 16rFF 16rFF 16rFF 16rFF 16rFF 16rFF 16rFF 16r7F ]) readInt64 equals: 9223372036854775807.
	self
		assert: (PBWireReader on: #[ 16r80 16r80 16r80 16r80 16r80 16r80 16r80 16r80 16r80 16r01 ]) readInt64
		equals: -9223372036854775808
]

{ #category : 'tests - tag' }
PBWireReaderTest >> testReadInvalidTag [
	"Wire types 6 and 7 do not exist; field number 0 is reserved."

	self should: [ (PBWireReader on: #[ 16r0E ]) readTag ] raise: PBWireError.
	self should: [ (PBWireReader on: #[ 16r0F ]) readTag ] raise: PBWireError.
	self should: [ (PBWireReader on: #[ 16r00 ]) readTag ] raise: PBWireError
]

{ #category : 'tests - length delimited' }
PBWireReaderTest >> testReadLengthDelimited [
	"Spec: 1a 03 08 96 01 is field 3 holding a message whose field 1 is 150; a trailing 10 05 follows (field 2 = 5)."

	| reader tag inner |
	reader := PBWireReader on: #[ 16r1A 16r03 16r08 16r96 16r01 16r10 16r05 ].
	tag := reader readTag.
	self assert: tag fieldNumber equals: 3.
	inner := reader readLengthDelimited.
	self assert: inner readTag fieldNumber equals: 1.
	self assert: inner readInt32 equals: 150.
	self assert: inner atEnd.
	self assert: reader readTag fieldNumber equals: 2.
	self assert: reader readVarint equals: 5.
	self assert: reader atEnd.
	"Packed repeated int32 [3, 270, 86942]"
	reader := PBWireReader on: #[ 16r06 16r03 16r8E 16r02 16r9E 16rA7 16r05 ].
	inner := reader readLengthDelimited.
	self assert: (Array streamContents: [ :s | [ inner atEnd ] whileFalse: [ s nextPut: inner readInt32 ] ]) equals: #( 3 270 86942 )
]

{ #category : 'tests - varint' }
PBWireReaderTest >> testReadSequenceAndAtEnd [

	| reader |
	reader := PBWireReader on: #[ 16r96 16r01 16r05 ].
	self deny: reader atEnd.
	self assert: reader readVarint equals: 150.
	self assert: reader readVarint equals: 5.
	self assert: reader atEnd
]

{ #category : 'tests - tag' }
PBWireReaderTest >> testReadTag [

	| tag |
	tag := (PBWireReader on: #[ 16r08 ]) readTag.
	self assert: tag fieldNumber equals: 1.
	self assert: tag wireType equals: PBWireType varint.
	tag := (PBWireReader on: #[ 16r12 ]) readTag.
	self assert: tag fieldNumber equals: 2.
	self assert: tag wireType equals: PBWireType len.
	tag := (PBWireReader on: #[ 16r1D ]) readTag.
	self assert: tag fieldNumber equals: 3.
	self assert: tag wireType equals: PBWireType i32.
	tag := (PBWireReader on: #[ 16r80 16r01 ]) readTag.
	self assert: tag fieldNumber equals: 16.
	self assert: tag wireType equals: PBWireType varint
]

{ #category : 'tests - varint' }
PBWireReaderTest >> testReadUnsignedZigZagBoolEnum [

	self assert: (PBWireReader on: #[ 16rFF 16rFF 16rFF 16rFF 16r0F ]) readUInt32 equals: 4294967295.
	self
		assert: (PBWireReader on: #[ 16rFF 16rFF 16rFF 16rFF 16rFF 16rFF 16rFF 16rFF 16rFF 16r01 ]) readUInt64
		equals: 18446744073709551615.
	self assert: (PBWireReader on: #[ 16r00 ]) readSInt32 equals: 0.
	self assert: (PBWireReader on: #[ 16r01 ]) readSInt32 equals: -1.
	self assert: (PBWireReader on: #[ 16r02 ]) readSInt32 equals: 1.
	self assert: (PBWireReader on: #[ 16r03 ]) readSInt32 equals: -2.
	self assert: (PBWireReader on: #[ 16rFF 16rFF 16rFF 16rFF 16r0F ]) readSInt32 equals: -2147483648.
	self
		assert: (PBWireReader on: #[ 16rFE 16rFF 16rFF 16rFF 16rFF 16rFF 16rFF 16rFF 16rFF 16r01 ]) readSInt64
		equals: 9223372036854775807.
	self
		assert: (PBWireReader on: #[ 16rFF 16rFF 16rFF 16rFF 16rFF 16rFF 16rFF 16rFF 16rFF 16r01 ]) readSInt64
		equals: -9223372036854775808.
	self assert: (PBWireReader on: #[ 16r01 ]) readBool.
	self deny: (PBWireReader on: #[ 16r00 ]) readBool.
	"Any non-zero varint is true"
	self assert: (PBWireReader on: #[ 16r96 16r01 ]) readBool.
	self assert: (PBWireReader on: #[ 16rFF 16rFF 16rFF 16rFF 16rFF 16rFF 16rFF 16rFF 16rFF 16r01 ]) readEnum equals: -1
]

{ #category : 'tests - varint' }
PBWireReaderTest >> testReadVarint [

	self assert: (PBWireReader on: #[ 16r00 ]) readVarint equals: 0.
	self assert: (PBWireReader on: #[ 16r7F ]) readVarint equals: 127.
	self assert: (PBWireReader on: #[ 16r96 16r01 ]) readVarint equals: 150.
	self assert: (PBWireReader on: #[ 16rAC 16r02 ]) readVarint equals: 300.
	self
		assert: (PBWireReader on: #[ 16rFF 16rFF 16rFF 16rFF 16rFF 16rFF 16rFF 16rFF 16rFF 16r01 ]) readVarint
		equals: 18446744073709551615
]

{ #category : 'tests - skip' }
PBWireReaderTest >> testSkipField [

	self assertSkipping: #[ 16r08 16r96 16r01 ] landsOnFieldTwo: 'varint'.
	self assertSkipping: #[ 16r09 1 2 3 4 5 6 7 8 ] landsOnFieldTwo: 'i64'.
	self assertSkipping: #[ 16r12 16r02 16rAA 16rBB ] landsOnFieldTwo: 'len'.
	self assertSkipping: #[ 16r1D 1 2 3 4 ] landsOnFieldTwo: 'i32'.
	"Group 4 { field 1 = 1; group 5 { field 1 = 2 } }"
	self assertSkipping: #[ 16r23 16r08 16r01 16r2B 16r08 16r02 16r2C 16r24 ] landsOnFieldTwo: 'nested group'
]

{ #category : 'tests - skip' }
PBWireReaderTest >> testSkipMalformedField [

	| reader |
	"Group 4 closed by end-group 5"
	reader := PBWireReader on: #[ 16r23 16r08 16r01 16r2C ].
	self should: [ reader skipField: reader readTag ] raise: PBWireError.
	"Unterminated group"
	reader := PBWireReader on: #[ 16r23 16r08 16r01 ].
	self should: [ reader skipField: reader readTag ] raise: PBWireError.
	"Stray end-group"
	reader := PBWireReader on: #[ 16r24 ].
	self should: [ reader skipField: reader readTag ] raise: PBWireError.
	"Truncated i64 / len"
	reader := PBWireReader on: #[ 16r09 1 2 3 ].
	self should: [ reader skipField: reader readTag ] raise: PBWireError.
	reader := PBWireReader on: #[ 16r12 16r05 1 ].
	self should: [ reader skipField: reader readTag ] raise: PBWireError
]

{ #category : 'tests - errors' }
PBWireReaderTest >> testSubReaderIsBounded [
	"The inner region is 1 byte (16r96, an unfinished varint) even though 16r01 follows in the buffer."

	| inner |
	inner := (PBWireReader on: #[ 16r01 16r96 16r01 ]) readLengthDelimited.
	self should: [ inner readVarint ] raise: PBWireError.
	inner := (PBWireReader on: #[ 16r02 16r01 16r02 16r03 16r04 ]) readLengthDelimited.
	self should: [ inner readFixed32 ] raise: PBWireError
]
