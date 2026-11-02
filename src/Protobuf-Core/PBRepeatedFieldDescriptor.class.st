"
I describe a repeated field. element is the descriptor of a single value (scalar or message); I hold the values in an OrderedCollection.
"
Class {
	#name : 'PBRepeatedFieldDescriptor',
	#superclass : 'PBFieldDescriptor',
	#instVars : [
		'element'
	],
	#category : 'Protobuf-Core-Runtime',
	#package : 'Protobuf-Core',
	#tag : 'Runtime'
}

{ #category : 'instance creation' }
PBRepeatedFieldDescriptor class >> element: aFieldDescriptor [

	^ self new setElement: aFieldDescriptor
]

{ #category : 'testing' }
PBRepeatedFieldDescriptor >> accepts: aTag [
	"One value per record, or (for packable types) a packed LEN record."

	^ (element accepts: aTag) or: [ element isPackable and: [ aTag wireType = PBWireType len ] ]
]

{ #category : 'testing' }
PBRepeatedFieldDescriptor >> isDefault: aCollection [

	^ aCollection isEmpty
]

{ #category : 'reading' }
PBRepeatedFieldDescriptor >> read: aReader tag: aTag into: aMessage [
	"Accept both the packed (one LEN record) and the unpacked (one record per value) encodings."

	| values packed |
	values := (aMessage instVarNamed: name) ifNil: [ aMessage instVarNamed: name put: OrderedCollection new ].
	(element isPackable and: [ aTag wireType = PBWireType len ]) ifFalse: [
			values add: (element readFrom: aReader).
			^ self ].
	packed := aReader readLengthDelimited.
	[ packed atEnd ] whileFalse: [ values add: (element readFrom: packed) ]
]

{ #category : 'initialization' }
PBRepeatedFieldDescriptor >> setElement: aFieldDescriptor [

	element := aFieldDescriptor.
	name := element name.
	number := element number.
	type := element type
]

{ #category : 'writing' }
PBRepeatedFieldDescriptor >> write: aCollection on: aWriter [
	"proto3 packs repeated numeric values by default."

	element isPackable ifFalse: [ ^ aCollection do: [ :each | element write: each on: aWriter ] ].
	aWriter writeTag: number wireType: PBWireType len.
	aWriter writeLengthDelimited: [ :inner | aCollection do: [ :each | element writeValue: each on: inner ] ]
]
