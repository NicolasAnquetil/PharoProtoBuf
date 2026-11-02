"
Tests PBMessage>>serialize on fixture messages against known protobuf bytes.
"
Class {
	#name : 'PBMessageSerializeTest',
	#superclass : 'TestCase',
	#category : 'Protobuf-Core-Tests-Tests',
	#package : 'Protobuf-Core-Tests',
	#tag : 'Tests'
}

{ #category : 'tests' }
PBMessageSerializeTest >> testDefaultValuesAreNotWritten [
	"proto3 implicit presence: a field holding its default is omitted."

	| message |
	message := PBExScalars new.
	message
		int32: 0;
		int64: 0;
		uint32: 0;
		uint64: 0;
		sint32: 0;
		sint64: 0;
		bool: false;
		enum: 0;
		fixed32: 0;
		sfixed32: 0;
		float: 0.0;
		fixed64: 0;
		sfixed64: 0;
		double: 0.0;
		string: '';
		bytes: #[  ].
	self assert: message serialize equals: #[  ].
	"-0.0 is not the default: its bit pattern differs"
	self
		assert: (PBExScalars new
				 double: Float negativeZero;
				 serialize)
		equals: #[ 16r71 0 0 0 0 0 0 0 16r80 ]
]

{ #category : 'tests' }
PBMessageSerializeTest >> testEmbeddedMessage [

	self
		assert: (PBExPerson new
				 name: 'A';
				 lastUpdated: (PBExTimestamp new seconds: 1);
				 serialize)
		equals: #[ 16r0A 16r01 16r41 16r2A 16r02 16r08 16r01 ].
	"A set but empty sub-message is still written"
	self
		assert: (PBExPerson new
				 lastUpdated: PBExTimestamp new;
				 serialize)
		equals: #[ 16r2A 16r00 ]
]

{ #category : 'tests' }
PBMessageSerializeTest >> testRepeatedMessages [

	| person |
	person := PBExPerson new.
	person phones
		add: (PBExPhoneNumber new
				 number: '5';
				 type: 1;
				 yourself);
		add: (PBExPhoneNumber new
				 number: '6';
				 yourself).
	self assert: person serialize equals: #[ 16r22 16r05 16r0A 16r01 16r35 16r10 16r01 16r22 16r03 16r0A 16r01 16r36 ].
	"An empty repeated field writes nothing"
	self
		assert: (PBExPerson new
				 phones;
				 serialize)
		equals: #[  ]
]

{ #category : 'tests' }
PBMessageSerializeTest >> testRepeatedScalars [

	| message |
	message := PBExRepeatedScalars new.
	message f addAll: #( 3 270 86942 ).
	"Spec example: packed int32 -> one LEN record"
	self assert: message serialize equals: #[ 16r32 16r06 16r03 16r8E 16r02 16r9E 16rA7 16r05 ].
	message := PBExRepeatedScalars new.
	message names addAll: #( 'a' 'b' ).
	message values add: 1.0.
	"Strings are never packed; doubles are"
	self assert: message serialize equals: #[ 16r3A 16r01 16r61 16r3A 16r01 16r62 16r42 16r08 0 0 0 0 0 0 16rF0 16r3F ]
]

{ #category : 'tests' }
PBMessageSerializeTest >> testScalarFields [

	self
		assert: (PBExTimestamp new
				 seconds: 1;
				 serialize)
		equals: #[ 16r08 16r01 ].
	self
		assert: (PBExTimestamp new
				 seconds: 150;
				 nanos: -1;
				 serialize)
		equals: #[ 16r08 16r96 16r01 16r10 16rFF 16rFF 16rFF 16rFF 16rFF 16rFF 16rFF 16rFF 16rFF 16r01 ]
]

{ #category : 'tests' }
PBMessageSerializeTest >> testUnknownFieldsArePreserved [
	"Fields 3 (len) and 111 (varint) are unknown to Timestamp. They are kept, and written after the known fields."

	| timestamp |
	timestamp := PBExTimestamp parseFrom: #[ 16r08 16r01 16r1A 16r02 16rAA 16rBB 16r10 16r05 16rF8 16r06 16r07 ].
	self assert: timestamp seconds equals: 1.
	self assert: timestamp nanos equals: 5.
	self assert: timestamp serialize equals: #[ 16r08 16r01 16r10 16r05 16r1A 16r02 16rAA 16rBB 16rF8 16r06 16r07 ]
]
