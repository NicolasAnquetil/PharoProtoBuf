"
I describe a field whose value is an embedded message (a PBMessage subclass), encoded length-delimited. Such a field has explicit presence: it is written whenever it is set, even when empty.
"
Class {
	#name : 'PBMessageFieldDescriptor',
	#superclass : 'PBFieldDescriptor',
	#instVars : [
		'messageClass'
	],
	#category : 'Protobuf-Core-Runtime',
	#package : 'Protobuf-Core',
	#tag : 'Runtime'
}

{ #category : 'instance creation' }
PBMessageFieldDescriptor class >> name: aName number: aNumber messageClass: aClass [

	^ self new setName: aName number: aNumber messageClass: aClass
]

{ #category : 'testing' }
PBMessageFieldDescriptor >> isDefault: aValue [
	"A set sub-message is always written, even when empty."

	^ false
]

{ #category : 'accessing' }
PBMessageFieldDescriptor >> messageClass [

	^ messageClass
]

{ #category : 'reading' }
PBMessageFieldDescriptor >> read: aReader tag: aTag into: aMessage [
	"A sub-message seen again is merged into the one already read, not replaced."

	| existing |
	existing := aMessage instVarNamed: name.
	existing
		ifNil: [ aMessage instVarNamed: name put: (self readFrom: aReader) ]
		ifNotNil: [ existing mergeFrom: aReader readLengthDelimited ]
]

{ #category : 'reading' }
PBMessageFieldDescriptor >> readFrom: aReader [

	^ messageClass new
		  mergeFrom: aReader readLengthDelimited;
		  yourself
]

{ #category : 'initialization' }
PBMessageFieldDescriptor >> setName: aName number: aNumber messageClass: aClass [

	name := aName.
	number := aNumber.
	type := #message.
	messageClass := aClass
]

{ #category : 'accessing' }
PBMessageFieldDescriptor >> wireType [

	^ PBWireType len
]

{ #category : 'writing' }
PBMessageFieldDescriptor >> write: aMessage on: aWriter [

	aWriter writeTag: number wireType: self wireType.
	aWriter writeLengthDelimited: [ :inner | aMessage writeOn: inner ]
]
