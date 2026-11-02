"
Tests PBMessage class>>parseFrom: on fixture messages from known protobuf bytes.
"
Class {
	#name : 'PBMessageParseTest',
	#superclass : 'TestCase',
	#category : 'Protobuf-Core-Tests-Tests',
	#package : 'Protobuf-Core-Tests',
	#tag : 'Tests'
}

{ #category : 'tests' }
PBMessageParseTest >> testAllScalarTypes [

	| m |
	m := PBExScalars parseFrom:
		     #[ 16r28 16r03 16r38 16r01 16r5D 16r00 16r00 16r80 16r3F 16r61 16rFE 16rFF 16rFF 16rFF 16rFF 16rFF 16rFF 16rFF 16r71 16r00
		        16r00 16r00 16r00 16r00 16r00 16rF0 16r3F 16r7A 16r07 16r74 16r65 16r73 16r74 16r69 16r6E 16r67 16r82 16r01 16r02 16r01
		        16r02 ]. "5 sint32 = -2" "7 bool = true" "11 float = 1.0" "12 fixed64 = 2^64 - 2" "14 double = 1.0" "15 string = 'testing'" "16 bytes = #[1 2] (tag needs 2 bytes)"
	self assert: m sint32 equals: -2.
	self assert: m bool.
	self assert: m float equals: 1.0.
	self assert: m fixed64 equals: 18446744073709551614.
	self assert: m double equals: 1.0.
	self assert: m string equals: 'testing'.
	self assert: m bytes equals: #[ 1 2 ].
	self assert: m int32 equals: 0
]

{ #category : 'tests' }
PBMessageParseTest >> testEmbeddedMessage [

	| person |
	person := PBExPerson parseFrom: #[ 16r0A 16r01 16r41 16r2A 16r02 16r08 16r01 16r10 16r07 ].
	self assert: person name equals: 'A'.
	self assert: person id equals: 7.
	self assert: person lastUpdated seconds equals: 1.
	self assert: (PBExPerson parseFrom: #[ 16r2A 16r00 ]) lastUpdated isNotNil.
	self assert: (PBExPerson parseFrom: #[  ]) lastUpdated isNil
]

{ #category : 'tests' }
PBMessageParseTest >> testRepeatedMessages [

	| person |
	"Elements may be interleaved with other fields; they are appended in order."
	person := PBExPerson parseFrom: #[ 16r22 16r05 16r0A 16r01 16r35 16r10 16r01 16r10 16r07 16r22 16r03 16r0A 16r01 16r36 ].
	self assert: person id equals: 7.
	self assert: (person phones collect: [ :p | p number ]) asArray equals: #( '5' '6' ).
	self assert: (person phones collect: [ :p | p type ]) asArray equals: #( 1 0 ).
	self assert: (PBExPerson parseFrom: #[  ]) phones isEmpty
]

{ #category : 'tests' }
PBMessageParseTest >> testRepeatedOccurrencesMerge [

	| person |
	"Scalar: last value wins"
	self assert: (PBExTimestamp parseFrom: #[ 16r08 16r01 16r08 16r02 ]) seconds equals: 2.
	"Sub-message: occurrences are merged (seconds from the first, nanos from the second)"
	person := PBExPerson parseFrom: #[ 16r2A 16r02 16r08 16r01 16r2A 16r02 16r10 16r05 ].
	self assert: person lastUpdated seconds equals: 1.
	self assert: person lastUpdated nanos equals: 5
]

{ #category : 'tests' }
PBMessageParseTest >> testRepeatedScalars [
	"Packed and unpacked encodings are both accepted, even mixed in one message."

	self
		assert: (PBExRepeatedScalars parseFrom: #[ 16r32 16r06 16r03 16r8E 16r02 16r9E 16rA7 16r05 ]) f asArray
		equals: #( 3 270 86942 ).
	self
		assert: (PBExRepeatedScalars parseFrom: #[ 16r30 16r03 16r30 16r8E 16r02 16r30 16r9E 16rA7 16r05 ]) f asArray
		equals: #( 3 270 86942 ).
	self assert: (PBExRepeatedScalars parseFrom: #[ 16r30 16r01 16r32 16r02 16r02 16r03 16r30 16r04 ]) f asArray equals: #( 1 2 3 4 ).
	self assert: (PBExRepeatedScalars parseFrom: #[ 16r3A 16r01 16r61 16r3A 16r01 16r62 ]) names asArray equals: #( 'a' 'b' )
]

{ #category : 'tests' }
PBMessageParseTest >> testScalarFields [

	| timestamp |
	timestamp := PBExTimestamp parseFrom: #[ 16r08 16r96 16r01 16r10 16rFF 16rFF 16rFF 16rFF 16rFF 16rFF 16rFF 16rFF 16rFF 16r01 ].
	self assert: timestamp seconds equals: 150.
	self assert: timestamp nanos equals: -1.
	"Any field order is accepted"
	timestamp := PBExTimestamp parseFrom: #[ 16r10 16r05 16r08 16r01 ].
	self assert: timestamp seconds equals: 1.
	self assert: timestamp nanos equals: 5.
	"Absent fields read as their default"
	timestamp := PBExTimestamp parseFrom: #[  ].
	self assert: timestamp seconds equals: 0.
	self assert: timestamp nanos equals: 0
]

{ #category : 'tests' }
PBMessageParseTest >> testWrongWireTypeIsTreatedAsUnknown [
	"Field 1 (int64 seconds) arrives as LEN: it is not decoded, but kept as an unknown field."

	| timestamp |
	timestamp := PBExTimestamp parseFrom: #[ 16r0A 16r01 16r05 16r10 16r07 ].
	self assert: timestamp seconds equals: 0.
	self assert: timestamp nanos equals: 7.
	self assert: timestamp serialize equals: #[ 16r10 16r07 16r0A 16r01 16r05 ].
	"Same for a message field arriving as a varint"
	self assert: (PBExPerson parseFrom: #[ 16r28 16r01 ]) lastUpdated isNil
]
