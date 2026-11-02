"
I describe one field of a protobuf message: the instance variable that holds it (name), its field number and its protobuf type (#int32, #string, #message...).
"
Class {
	#name : 'PBFieldDescriptor',
	#superclass : 'Object',
	#instVars : [
		'name',
		'number',
		'type'
	],
	#category : 'Protobuf-Core-Runtime',
	#package : 'Protobuf-Core',
	#tag : 'Runtime'
}

{ #category : 'instance creation' }
PBFieldDescriptor class >> name: aName number: aNumber type: aType [

	^ self new setName: aName number: aNumber type: aType
]

{ #category : 'types' }
PBFieldDescriptor class >> scalarTypes [
	"protobuf type -> { wire-method suffix. wire type }.
	The suffix names PBWireWriter>>write<Suffix>: and PBWireReader>>read<Suffix>."

	^ Dictionary new
		  at: #int32 put: {
				  'Int32'.
				  PBWireType varint };
		  at: #int64 put: {
				  'Int64'.
				  PBWireType varint };
		  at: #uint32 put: {
				  'UInt32'.
				  PBWireType varint };
		  at: #uint64 put: {
				  'UInt64'.
				  PBWireType varint };
		  at: #sint32 put: {
				  'SInt32'.
				  PBWireType varint };
		  at: #sint64 put: {
				  'SInt64'.
				  PBWireType varint };
		  at: #bool put: {
				  'Bool'.
				  PBWireType varint };
		  at: #enum put: {
				  'Enum'.
				  PBWireType varint };
		  at: #fixed32 put: {
				  'Fixed32'.
				  PBWireType i32 };
		  at: #sfixed32 put: {
				  'SFixed32'.
				  PBWireType i32 };
		  at: #float put: {
				  'Float'.
				  PBWireType i32 };
		  at: #fixed64 put: {
				  'Fixed64'.
				  PBWireType i64 };
		  at: #sfixed64 put: {
				  'SFixed64'.
				  PBWireType i64 };
		  at: #double put: {
				  'Double'.
				  PBWireType i64 };
		  at: #string put: {
				  'String'.
				  PBWireType len };
		  at: #bytes put: {
				  'Bytes'.
				  PBWireType len };
		  yourself
]

{ #category : 'testing' }
PBFieldDescriptor >> accepts: aTag [
	"Answer whether a record with aTag can be decoded as this field."

	^ aTag wireType = self wireType
]

{ #category : 'testing' }
PBFieldDescriptor >> isDefault: aValue [
	"proto3 default for my type. -0.0 is not the default: only +0.0 is."

	(#( #string #bytes ) includes: type) ifTrue: [ ^ aValue isEmpty ].
	type = #bool ifTrue: [ ^ aValue not ].
	(#( #float #double ) includes: type) ifTrue: [ ^ aValue = 0 and: [ aValue asFloat signBit = 0 ] ].
	^ aValue = 0
]

{ #category : 'testing' }
PBFieldDescriptor >> isPackable [
	"Repeated values of fixed-size or varint types can be packed in one length-delimited record."

	^ self wireType ~= PBWireType len
]

{ #category : 'accessing' }
PBFieldDescriptor >> name [

	^ name
]

{ #category : 'accessing' }
PBFieldDescriptor >> number [

	^ number
]

{ #category : 'reading' }
PBFieldDescriptor >> read: aReader tag: aTag into: aMessage [

	aMessage instVarNamed: name put: (self readFrom: aReader)
]

{ #category : 'reading' }
PBFieldDescriptor >> readFrom: aReader [

	^ aReader perform: self readSelector
]

{ #category : 'accessing' }
PBFieldDescriptor >> readSelector [

	^ ('read{1}' format: { (self class scalarTypes at: type) first }) asSymbol
]

{ #category : 'initialization' }
PBFieldDescriptor >> setName: aName number: aNumber type: aType [

	(self class scalarTypes includesKey: aType) ifFalse: [ self error: 'Unknown protobuf type ' , aType printString ].
	name := aName.
	number := aNumber.
	type := aType
]

{ #category : 'accessing' }
PBFieldDescriptor >> type [

	^ type
]

{ #category : 'accessing' }
PBFieldDescriptor >> wireType [

	^ (self class scalarTypes at: type) second
]

{ #category : 'writing' }
PBFieldDescriptor >> write: aValue on: aWriter [

	aWriter writeTag: number wireType: self wireType.
	self writeValue: aValue on: aWriter
]

{ #category : 'accessing' }
PBFieldDescriptor >> writeSelector [

	^ ('write{1}:' format: { (self class scalarTypes at: type) first }) asSymbol
]

{ #category : 'writing' }
PBFieldDescriptor >> writeValue: aValue on: aWriter [
	"Write aValue without its tag."

	aWriter perform: self writeSelector with: aValue
]
