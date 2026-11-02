"
Hand-written fixture with repeated scalar fields (proto3, so numeric ones are packed):
message RepeatedScalars { repeated int32 f = 6; repeated string names = 7; repeated double values = 8; }
"
Class {
	#name : 'PBExRepeatedScalars',
	#superclass : 'PBMessage',
	#instVars : [
		'f',
		'names',
		'values'
	],
	#category : 'Protobuf-Core-Tests-Fixtures',
	#package : 'Protobuf-Core-Tests',
	#tag : 'Fixtures'
}

{ #category : 'descriptor' }
PBExRepeatedScalars class >> descriptor [

	^ PBMessageDescriptor new
		  repeated: #f number: 6 type: #int32;
		  repeated: #names number: 7 type: #string;
		  repeated: #values number: 8 type: #double;
		  yourself
]

{ #category : 'accessing' }
PBExRepeatedScalars >> f [

	^ f ifNil: [ f := OrderedCollection new ]
]

{ #category : 'accessing' }
PBExRepeatedScalars >> names [

	^ names ifNil: [ names := OrderedCollection new ]
]

{ #category : 'accessing' }
PBExRepeatedScalars >> values [

	^ values ifNil: [ values := OrderedCollection new ]
]
