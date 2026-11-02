"
Hand-written fixture with one proto3 field of every scalar type, numbered 1 to 16 in the order of my instance variables:
message Scalars { int32 int32 = 1; int64 int64 = 2; uint32 uint32 = 3; uint64 uint64 = 4; sint32 sint32 = 5; sint64 sint64 = 6; bool bool = 7; SomeEnum enum = 8; fixed32 fixed32 = 9; sfixed32 sfixed32 = 10; float float = 11; fixed64 fixed64 = 12; sfixed64 sfixed64 = 13; double double = 14; string string = 15; bytes bytes = 16; }
"
Class {
	#name : 'PBExScalars',
	#superclass : 'PBMessage',
	#instVars : [
		'int32',
		'int64',
		'uint32',
		'uint64',
		'sint32',
		'sint64',
		'bool',
		'enum',
		'fixed32',
		'sfixed32',
		'float',
		'fixed64',
		'sfixed64',
		'double',
		'string',
		'bytes'
	],
	#category : 'Protobuf-Core-Tests-Fixtures',
	#package : 'Protobuf-Core-Tests',
	#tag : 'Fixtures'
}

{ #category : 'descriptor' }
PBExScalars class >> descriptor [
	"Field i is the i-th instance variable, and its protobuf type has the same name."
	| descriptor |
	descriptor := PBMessageDescriptor new.
	self slotNames doWithIndex: [ :each :i | descriptor field: each number: i type: each ].
	^ descriptor
]

{ #category : 'accessing' }
PBExScalars >> bool [
	^ bool ifNil: [ false ]
]

{ #category : 'accessing' }
PBExScalars >> bool: aValue [
	bool := aValue
]

{ #category : 'accessing' }
PBExScalars >> bytes [
	^ bytes ifNil: [ #[] ]
]

{ #category : 'accessing' }
PBExScalars >> bytes: aValue [
	bytes := aValue
]

{ #category : 'accessing' }
PBExScalars >> double [
	^ double ifNil: [ 0.0 ]
]

{ #category : 'accessing' }
PBExScalars >> double: aValue [
	double := aValue
]

{ #category : 'accessing' }
PBExScalars >> enum [
	^ enum ifNil: [ 0 ]
]

{ #category : 'accessing' }
PBExScalars >> enum: aValue [
	enum := aValue
]

{ #category : 'accessing' }
PBExScalars >> fixed32 [
	^ fixed32 ifNil: [ 0 ]
]

{ #category : 'accessing' }
PBExScalars >> fixed32: aValue [
	fixed32 := aValue
]

{ #category : 'accessing' }
PBExScalars >> fixed64 [
	^ fixed64 ifNil: [ 0 ]
]

{ #category : 'accessing' }
PBExScalars >> fixed64: aValue [
	fixed64 := aValue
]

{ #category : 'accessing' }
PBExScalars >> float [
	^ float ifNil: [ 0.0 ]
]

{ #category : 'accessing' }
PBExScalars >> float: aValue [
	float := aValue
]

{ #category : 'accessing' }
PBExScalars >> int32 [
	^ int32 ifNil: [ 0 ]
]

{ #category : 'accessing' }
PBExScalars >> int32: aValue [
	int32 := aValue
]

{ #category : 'accessing' }
PBExScalars >> int64 [
	^ int64 ifNil: [ 0 ]
]

{ #category : 'accessing' }
PBExScalars >> int64: aValue [
	int64 := aValue
]

{ #category : 'accessing' }
PBExScalars >> sfixed32 [
	^ sfixed32 ifNil: [ 0 ]
]

{ #category : 'accessing' }
PBExScalars >> sfixed32: aValue [
	sfixed32 := aValue
]

{ #category : 'accessing' }
PBExScalars >> sfixed64 [
	^ sfixed64 ifNil: [ 0 ]
]

{ #category : 'accessing' }
PBExScalars >> sfixed64: aValue [
	sfixed64 := aValue
]

{ #category : 'accessing' }
PBExScalars >> sint32 [
	^ sint32 ifNil: [ 0 ]
]

{ #category : 'accessing' }
PBExScalars >> sint32: aValue [
	sint32 := aValue
]

{ #category : 'accessing' }
PBExScalars >> sint64 [
	^ sint64 ifNil: [ 0 ]
]

{ #category : 'accessing' }
PBExScalars >> sint64: aValue [
	sint64 := aValue
]

{ #category : 'accessing' }
PBExScalars >> string [
	^ string ifNil: [ '' ]
]

{ #category : 'accessing' }
PBExScalars >> string: aValue [
	string := aValue
]

{ #category : 'accessing' }
PBExScalars >> uint32 [
	^ uint32 ifNil: [ 0 ]
]

{ #category : 'accessing' }
PBExScalars >> uint32: aValue [
	uint32 := aValue
]

{ #category : 'accessing' }
PBExScalars >> uint64 [
	^ uint64 ifNil: [ 0 ]
]

{ #category : 'accessing' }
PBExScalars >> uint64: aValue [
	uint64 := aValue
]
