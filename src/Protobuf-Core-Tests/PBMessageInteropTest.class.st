"
Tests PBMessage against data written by the official protobuf Java implementation (PBExAddressBook class>>sampleBytes).
"
Class {
	#name : 'PBMessageInteropTest',
	#superclass : 'TestCase',
	#category : 'Protobuf-Core-Tests-Tests',
	#package : 'Protobuf-Core-Tests',
	#tag : 'Tests'
}

{ #category : 'tests' }
PBMessageInteropTest >> testParseJavaAddressBook [
	"Expected values from samples/addressbook-sample.txt (protoc --decode)."

	| people alice elodie |
	people := (PBExAddressBook parseFrom: PBExAddressBook sampleBytes) people.
	self assert: people size equals: 9.
	self assert: (people collect: [ :p | p id ]) asArray equals: #( 1 -1 2147483647 -2147483648 0 150 300 42 7 ).
	alice := people first.
	self assert: alice name equals: 'Alice Martin'.
	self assert: alice email equals: 'alice@example.com'.
	self assert: (alice phones collect: [ :p | p number -> p type ]) asArray equals: {
			('+33 1 23 45 67 89' -> 1).
			('+33 6 12 34 56 78' -> 0).
			('+33 1 98 76 54 32' -> 2) }.
	self assert: alice lastUpdated seconds > 1700000000.
	self assert: (people at: 3) lastUpdated isNil.
	elodie := people at: 6.
	"'Élodie Cœur ' then three CJK ideographs, a space and an emoji"
	self assert: elodie name equals: (String withAll: {
				 $É.
				 $l.
				 $o.
				 $d.
				 $i.
				 $e.
				 $ .
				 $C.
				 (Character value: 16r153).
				 $u.
				 $r.
				 $ .
				 (Character value: 16r674E).
				 (Character value: 16r5C0F).
				 (Character value: 16r9F8D).
				 $ .
				 (Character value: 16r1F600) }).
	self assert: (people at: 7) name size equals: 144
]

{ #category : 'tests' }
PBMessageInteropTest >> testReserializeJavaAddressBookIdentically [
	"Java writes fields in field-number order, as PBMessage does, so the bytes must match exactly."

	self assert: (PBExAddressBook parseFrom: PBExAddressBook sampleBytes) serialize equals: PBExAddressBook sampleBytes
]
