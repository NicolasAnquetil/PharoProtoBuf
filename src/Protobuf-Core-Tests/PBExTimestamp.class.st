"
Hand-written fixture for google.protobuf.Timestamp { int64 seconds = 1; int32 nanos = 2; }
"
Class {
	#name : 'PBExTimestamp',
	#superclass : 'PBMessage',
	#instVars : [
		'seconds',
		'nanos'
	],
	#category : 'Protobuf-Core-Tests-Fixtures',
	#package : 'Protobuf-Core-Tests',
	#tag : 'Fixtures'
}

{ #category : 'descriptor' }
PBExTimestamp class >> descriptor [

	^ PBMessageDescriptor new
		  field: #seconds number: 1 type: #int64;
		  field: #nanos number: 2 type: #int32;
		  yourself
]

{ #category : 'accessing' }
PBExTimestamp >> nanos [

	^ nanos ifNil: [ 0 ]
]

{ #category : 'accessing' }
PBExTimestamp >> nanos: anInteger [

	nanos := anInteger
]

{ #category : 'accessing' }
PBExTimestamp >> seconds [

	^ seconds ifNil: [ 0 ]
]

{ #category : 'accessing' }
PBExTimestamp >> seconds: anInteger [

	seconds := anInteger
]
