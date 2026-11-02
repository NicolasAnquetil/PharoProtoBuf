"
I decode protobuf wire-format primitives from a ByteArray. Malformed input (truncation, overlong varints, bad tags, invalid UTF-8) raises PBWireError.

Example: decode a message { string name = 1; int32 id = 2; }, skipping unknown fields:

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
	{ name. id }.	""#('Alice' 150)""

readLengthDelimited answers a sub-reader bounded to an embedded message or packed field.

Implementation: position is the index of the last consumed byte; limit is the index of the last readable byte (sub-readers share bytes but have narrower bounds).
"
Class {
	#name : 'PBWireReader',
	#superclass : 'Object',
	#instVars : [
		'bytes',
		'position',
		'limit'
	],
	#category : 'Protobuf-Core-Wire',
	#package : 'Protobuf-Core',
	#tag : 'Wire'
}

{ #category : 'examples' }
PBWireReader class >> exampleAddressBook [
	"Decode samples/addressbook-sample.bin (written by the official protobuf Java example,
	see samples/addressbook.proto) by hand, field by field, and inspect the result.
	Each person is a Dictionary with #name, #id, #email, #phones (type -> number) and, when set, #lastUpdated.
	Assumes the sample file is in current directory, `addressbook-sample.bin`."

	<example>
	| bytes book people |
	bytes := 'addressbook-sample.bin' asFileReference binaryReadStream upToEnd.
	book := self on: bytes.
	people := OrderedCollection new.
	[ book atEnd ] whileFalse: [
			| tag person p |
			tag := book readTag. "AddressBook field 1 = repeated Person people"
			person := book readLengthDelimited.
			"proto3 does not write default values, so set them first"
			p := Dictionary new.
			p
				at: #id put: 0;
				at: #email put: '';
				at: #phones put: OrderedCollection new.
			[ person atEnd ] whileFalse: [
					| t |
					t := person readTag.
					t fieldNumber = 1 ifTrue: [ p at: #name put: person readString ].
					t fieldNumber = 2 ifTrue: [ p at: #id put: person readInt32 ].
					t fieldNumber = 3 ifTrue: [ p at: #email put: person readString ].
					t fieldNumber = 4 ifTrue: [
							| phone number type |
							"repeated PhoneNumber phones"
							phone := person readLengthDelimited.
							number := ''. "string default"
							type := #MOBILE. "enum default (0)"
							[ phone atEnd ] whileFalse: [
									| pt |
									pt := phone readTag.
									pt fieldNumber = 1
										ifTrue: [ number := phone readString ]
										ifFalse: [
												pt fieldNumber = 2
													ifTrue: [ type := #( #MOBILE #HOME #WORK ) at: phone readEnum + 1 ]
													ifFalse: [ phone skipField: pt ] ] ].
							(p at: #phones) add: type -> number ].
					t fieldNumber = 5 ifTrue: [
							| ts seconds nanos |
							"google.protobuf.Timestamp last_updated"
							ts := person readLengthDelimited.
							seconds := 0.
							nanos := 0.
							[ ts atEnd ] whileFalse: [
									| tt |
									tt := ts readTag.
									tt fieldNumber = 1
										ifTrue: [ seconds := ts readInt64 ]
										ifFalse: [
												tt fieldNumber = 2
													ifTrue: [ nanos := ts readInt32 ]
													ifFalse: [ ts skipField: tt ] ] ].
							p at: #lastUpdated put: (DateAndTime fromUnixTime: seconds) + (Duration nanoSeconds: nanos) ].
					(t fieldNumber between: 1 and: 5) ifFalse: [ person skipField: t ] ]. "unknown fields"
			people add: p ].
	^ people inspect
]

{ #category : 'instance creation' }
PBWireReader class >> on: aByteArray [

	^ self new setBytes: aByteArray position: 0 limit: aByteArray size
]

{ #category : 'testing' }
PBWireReader >> atEnd [

	^ position >= limit
]

{ #category : 'accessing' }
PBWireReader >> bytesFrom: aMark [
	"Answer a copy of the raw bytes consumed since aMark (a previous #position)."

	^ bytes copyFrom: aMark + 1 to: position
]

{ #category : 'private' }
PBWireReader >> ensureAvailable: byteCount [

	position + byteCount > limit ifTrue: [ PBWireError signal: ('Length {1} exceeds remaining input' format: { byteCount }) ]
]

{ #category : 'private' }
PBWireReader >> nextByte [

	position >= limit ifTrue: [ PBWireError signal: 'Unexpected end of input' ].
	position := position + 1.
	^ bytes at: position
]

{ #category : 'accessing' }
PBWireReader >> position [
	"Answer the number of bytes consumed so far; use it as a mark for #bytesFrom:."

	^ position
]

{ #category : 'reading - varint' }
PBWireReader >> readBool [

	^ self readVarint ~= 0
]

{ #category : 'reading - length delimited' }
PBWireReader >> readBytes [

	| length result |
	length := self readVarint.
	self ensureAvailable: length.
	result := bytes copyFrom: position + 1 to: position + length.
	position := position + length.
	^ result
]

{ #category : 'reading - fixed' }
PBWireReader >> readDouble [

	^ Float fromIEEE64Bit: self readFixed64
]

{ #category : 'reading - varint' }
PBWireReader >> readEnum [

	^ self readInt32
]

{ #category : 'reading - fixed' }
PBWireReader >> readFixed32 [

	^ self readLittleEndian: 4
]

{ #category : 'reading - fixed' }
PBWireReader >> readFixed64 [

	^ self readLittleEndian: 8
]

{ #category : 'reading - fixed' }
PBWireReader >> readFloat [

	^ Float fromIEEE32Bit: self readFixed32
]

{ #category : 'reading - varint' }
PBWireReader >> readInt32 [

	^ self signed: self readVarint bits: 32
]

{ #category : 'reading - varint' }
PBWireReader >> readInt64 [

	^ self signed: self readVarint bits: 64
]

{ #category : 'reading - length delimited' }
PBWireReader >> readLengthDelimited [
	"Answer a reader over the next length-prefixed region, and skip past it."

	| length sub |
	length := self readVarint.
	self ensureAvailable: length.
	sub := self class new setBytes: bytes position: position limit: position + length.
	position := position + length.
	^ sub
]

{ #category : 'private' }
PBWireReader >> readLittleEndian: byteCount [

	| value |
	value := 0.
	0 to: byteCount - 1 do: [ :i | value := value + (self nextByte bitShift: 8 * i) ].
	^ value
]

{ #category : 'reading - fixed' }
PBWireReader >> readSFixed32 [

	^ self signed: self readFixed32 bits: 32
]

{ #category : 'reading - fixed' }
PBWireReader >> readSFixed64 [

	^ self signed: self readFixed64 bits: 64
]

{ #category : 'reading - varint' }
PBWireReader >> readSInt32 [

	^ self unZigZag: (self readVarint bitAnd: 16rFFFFFFFF)
]

{ #category : 'reading - varint' }
PBWireReader >> readSInt64 [

	^ self unZigZag: (self readVarint bitAnd: 16rFFFFFFFFFFFFFFFF)
]

{ #category : 'reading - length delimited' }
PBWireReader >> readString [

	^ [ self readBytes utf8Decoded ]
		  on: ZnCharacterEncodingError
		  do: [ :e | PBWireError signal: 'Invalid UTF-8 in string field' ]
]

{ #category : 'reading - tag' }
PBWireReader >> readTag [

	| key fieldNumber wireType |
	key := self readVarint.
	fieldNumber := key bitShift: -3.
	wireType := key bitAnd: 7.
	fieldNumber = 0 ifTrue: [ PBWireError signal: 'Invalid field number 0' ].
	wireType > PBWireType i32 ifTrue: [ PBWireError signal: 'Invalid wire type ' , wireType printString ].
	^ PBTag fieldNumber: fieldNumber wireType: wireType
]

{ #category : 'reading - varint' }
PBWireReader >> readUInt32 [

	^ self readVarint bitAnd: 16rFFFFFFFF
]

{ #category : 'reading - varint' }
PBWireReader >> readUInt64 [

	^ self readVarint bitAnd: 16rFFFFFFFFFFFFFFFF
]

{ #category : 'reading - varint' }
PBWireReader >> readVarint [
	"At most 10 bytes: enough for 64 bits."

	| result shift byte |
	result := 0.
	shift := 0.
	[
		shift >= 70 ifTrue: [ PBWireError signal: 'Varint longer than 10 bytes' ].
		byte := self nextByte.
		result := result + ((byte bitAnd: 16r7F) bitShift: shift).
		shift := shift + 7.
		byte >= 16r80 ] whileTrue.
	^ result
]

{ #category : 'initialization' }
PBWireReader >> setBytes: aByteArray position: aPosition limit: aLimit [

	bytes := aByteArray.
	position := aPosition.
	limit := aLimit
]

{ #category : 'private' }
PBWireReader >> signed: anUnsignedInteger bits: bitCount [
	"Interpret the low bitCount bits of anUnsignedInteger as two's complement."

	| value |
	value := anUnsignedInteger bitAnd: (1 bitShift: bitCount) - 1.
	^ value >= (1 bitShift: bitCount - 1)
		  ifTrue: [ value - (1 bitShift: bitCount) ]
		  ifFalse: [ value ]
]

{ #category : 'private' }
PBWireReader >> skipBytes: byteCount [

	self ensureAvailable: byteCount.
	position := position + byteCount
]

{ #category : 'reading - skip' }
PBWireReader >> skipField: aTag [
	"Skip the value of the field whose tag was just read (used for unknown fields)."

	| wireType |
	wireType := aTag wireType.
	wireType = PBWireType varint ifTrue: [ ^ self readVarint ].
	wireType = PBWireType i64 ifTrue: [ ^ self skipBytes: 8 ].
	wireType = PBWireType len ifTrue: [ ^ self skipBytes: self readVarint ].
	wireType = PBWireType i32 ifTrue: [ ^ self skipBytes: 4 ].
	wireType = PBWireType sgroup ifTrue: [ ^ self skipGroup: aTag fieldNumber ].
	PBWireError signal: 'Unexpected end-group for field ' , aTag fieldNumber printString
]

{ #category : 'private' }
PBWireReader >> skipGroup: aFieldNumber [
	"Skip fields until the end-group tag matching aFieldNumber; nested groups recurse through skipField:."

	| tag |
	[
		tag := self readTag.
		tag wireType = PBWireType egroup ] whileFalse: [ self skipField: tag ].
	tag fieldNumber = aFieldNumber ifFalse: [
			PBWireError signal: ('Group {1} closed by end-group {2}' format: {
						 aFieldNumber.
						 tag fieldNumber }) ]
]

{ #category : 'private' }
PBWireReader >> unZigZag: anUnsignedInteger [

	^ anUnsignedInteger even
		  ifTrue: [ anUnsignedInteger bitShift: -1 ]
		  ifFalse: [ ((anUnsignedInteger bitShift: -1) + 1) negated ]
]
