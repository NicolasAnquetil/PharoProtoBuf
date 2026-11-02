"
Hand-written fixture for tutorial.Person from samples/addressbook.proto:
message Person { string name = 1; int32 id = 2; string email = 3; repeated PhoneNumber phones = 4; google.protobuf.Timestamp last_updated = 5; }
"
Class {
	#name : 'PBExPerson',
	#superclass : 'PBMessage',
	#instVars : [
		'name',
		'id',
		'email',
		'phones',
		'lastUpdated'
	],
	#category : 'Protobuf-Core-Tests-Fixtures',
	#package : 'Protobuf-Core-Tests',
	#tag : 'Fixtures'
}

{ #category : 'descriptor' }
PBExPerson class >> descriptor [

	^ PBMessageDescriptor new
		  field: #name number: 1 type: #string;
		  field: #id number: 2 type: #int32;
		  field: #email number: 3 type: #string;
		  repeated: #phones number: 4 message: PBExPhoneNumber;
		  field: #lastUpdated number: 5 message: PBExTimestamp;
		  yourself
]

{ #category : 'accessing' }
PBExPerson >> email [

	^ email ifNil: [ '' ]
]

{ #category : 'accessing' }
PBExPerson >> email: aString [

	email := aString
]

{ #category : 'accessing' }
PBExPerson >> id [

	^ id ifNil: [ 0 ]
]

{ #category : 'accessing' }
PBExPerson >> id: anInteger [

	id := anInteger
]

{ #category : 'accessing' }
PBExPerson >> lastUpdated [
	"nil when not set (a message field has explicit presence)"

	^ lastUpdated
]

{ #category : 'accessing' }
PBExPerson >> lastUpdated: aTimestamp [

	lastUpdated := aTimestamp
]

{ #category : 'accessing' }
PBExPerson >> name [

	^ name ifNil: [ '' ]
]

{ #category : 'accessing' }
PBExPerson >> name: aString [

	name := aString
]

{ #category : 'accessing' }
PBExPerson >> phones [

	^ phones ifNil: [ phones := OrderedCollection new ]
]
