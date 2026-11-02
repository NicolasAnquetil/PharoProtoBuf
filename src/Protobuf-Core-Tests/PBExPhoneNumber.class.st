"
Hand-written fixture for tutorial.Person.PhoneNumber from samples/addressbook.proto:
message PhoneNumber { string number = 1; PhoneType type = 2; }  with enum PhoneType { MOBILE = 0; HOME = 1; WORK = 2; }
The enum is held as its integer value.
"
Class {
	#name : 'PBExPhoneNumber',
	#superclass : 'PBMessage',
	#instVars : [
		'number',
		'type'
	],
	#category : 'Protobuf-Core-Tests-Fixtures',
	#package : 'Protobuf-Core-Tests',
	#tag : 'Fixtures'
}

{ #category : 'descriptor' }
PBExPhoneNumber class >> descriptor [

	^ PBMessageDescriptor new
		  field: #number number: 1 type: #string;
		  field: #type number: 2 type: #enum;
		  yourself
]

{ #category : 'accessing' }
PBExPhoneNumber >> number [

	^ number ifNil: [ '' ]
]

{ #category : 'accessing' }
PBExPhoneNumber >> number: aString [

	number := aString
]

{ #category : 'accessing' }
PBExPhoneNumber >> type [
	"0 MOBILE, 1 HOME, 2 WORK"

	^ type ifNil: [ 0 ]
]

{ #category : 'accessing' }
PBExPhoneNumber >> type: anInteger [

	type := anInteger
]
