"
I am a decoded field key: a field number and a wire type (see PBWireType).
"
Class {
	#name : 'PBTag',
	#superclass : 'Object',
	#instVars : [
		'fieldNumber',
		'wireType'
	],
	#category : 'Protobuf-Core',
	#package : 'Protobuf-Core'
}

{ #category : 'instance creation' }
PBTag class >> fieldNumber: aFieldNumber wireType: aWireType [

	^ self new setFieldNumber: aFieldNumber wireType: aWireType
]

{ #category : 'accessing' }
PBTag >> fieldNumber [

	^ fieldNumber
]

{ #category : 'printing' }
PBTag >> printOn: aStream [

	aStream << 'PBTag(' << fieldNumber printString << ', ' << wireType printString << ')'
]

{ #category : 'initialization' }
PBTag >> setFieldNumber: aFieldNumber wireType: aWireType [

	fieldNumber := aFieldNumber.
	wireType := aWireType
]

{ #category : 'accessing' }
PBTag >> wireType [

	^ wireType
]
