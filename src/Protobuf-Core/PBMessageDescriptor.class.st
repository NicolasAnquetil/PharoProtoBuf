"
I describe the fields of a protobuf message type: a collection of PBFieldDescriptor, looked up by field number.
"
Class {
	#name : 'PBMessageDescriptor',
	#superclass : 'Object',
	#instVars : [
		'fields'
	],
	#category : 'Protobuf-Core-Runtime',
	#package : 'Protobuf-Core',
	#tag : 'Runtime'
}

{ #category : 'building' }
PBMessageDescriptor >> field: aName number: aNumber message: aMessageClass [

	fields add: (PBMessageFieldDescriptor name: aName number: aNumber messageClass: aMessageClass)
]

{ #category : 'building' }
PBMessageDescriptor >> field: aName number: aNumber type: aType [

	fields add: (PBFieldDescriptor name: aName number: aNumber type: aType)
]

{ #category : 'accessing' }
PBMessageDescriptor >> fieldAt: aNumber ifAbsent: aBlock [

	^ fields detect: [ :each | each number = aNumber ] ifNone: aBlock
]

{ #category : 'accessing' }
PBMessageDescriptor >> fields [
	"Answer my field descriptors in increasing field-number order (the order they are serialized in)."

	^ fields
]

{ #category : 'initialization' }
PBMessageDescriptor >> initialize [

	super initialize.
	fields := SortedCollection sortBlock: [ :a :b | a number <= b number ]
]

{ #category : 'building' }
PBMessageDescriptor >> repeated: aName number: aNumber message: aMessageClass [

	fields add:
		(PBRepeatedFieldDescriptor element: (PBMessageFieldDescriptor name: aName number: aNumber messageClass: aMessageClass))
]

{ #category : 'building' }
PBMessageDescriptor >> repeated: aName number: aNumber type: aType [

	fields add: (PBRepeatedFieldDescriptor element: (PBFieldDescriptor name: aName number: aNumber type: aType))
]
