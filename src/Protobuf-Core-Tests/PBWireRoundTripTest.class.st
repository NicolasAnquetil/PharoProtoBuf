"
Checks that values written by PBWireWriter are read back unchanged by PBWireReader, at the range boundaries of every protobuf scalar type.
"
Class {
	#name : 'PBWireRoundTripTest',
	#superclass : 'TestCase',
	#category : 'Protobuf-Core-Tests',
	#package : 'Protobuf-Core-Tests'
}

{ #category : 'helpers' }
PBWireRoundTripTest >> assertValues: aCollection roundTripThrough: aSymbol [
	"aSymbol is a type name such as #Int32: uses writeInt32: and readInt32."

	| writeSelector readSelector |
	writeSelector := ('write' , aSymbol , ':') asSymbol.
	readSelector := ('read' , aSymbol) asSymbol.
	aCollection do: [ :value |
			| writer reader |
			writer := PBWireWriter new.
			writer perform: writeSelector with: value.
			reader := PBWireReader on: writer contents.
			self assert: (reader perform: readSelector) equals: value.
			self assert: reader atEnd ]
]

{ #category : 'tests' }
PBWireRoundTripTest >> testIntegerBoundaries [

	| int32 int64 |
	int32 := #( -2147483648 -2147483647 -129 -128 -1 0 1 127 128 16383 16384 2147483647 ).
	int64 := #( -9223372036854775808 -2147483649 -1 0 2147483648 4294967296 9223372036854775807 ).
	self assertValues: int32 roundTripThrough: #Int32.
	self assertValues: int32 roundTripThrough: #SInt32.
	self assertValues: int32 roundTripThrough: #SFixed32.
	self assertValues: int32 roundTripThrough: #Enum.
	self assertValues: int32 , int64 roundTripThrough: #Int64.
	self assertValues: int32 , int64 roundTripThrough: #SInt64.
	self assertValues: int32 , int64 roundTripThrough: #SFixed64.
	self assertValues: #( 0 1 127 128 2147483648 4294967295 ) roundTripThrough: #UInt32.
	self assertValues: #( 0 1 127 128 2147483648 4294967295 ) roundTripThrough: #Fixed32.
	self assertValues: #( 0 4294967296 9223372036854775808 18446744073709551615 ) roundTripThrough: #UInt64.
	self assertValues: #( 0 4294967296 9223372036854775808 18446744073709551615 ) roundTripThrough: #Fixed64
]

{ #category : 'tests' }
PBWireRoundTripTest >> testOtherScalars [

	self assertValues: #( true false ) roundTripThrough: #Bool.
	self
		assertValues: {
				0.0.
				1.0.
				-2.5.
				Float fmax.
				Float fminDenormalized.
				Float infinity.
				Float negativeInfinity }
		roundTripThrough: #Double.
	self
		assertValues: {
				0.0.
				1.0.
				-2.5.
				0.5.
				Float infinity.
				Float negativeInfinity }
		roundTripThrough: #Float.
	self
		assertValues: {
				''.
				'hello'.
				(String new: 300 withAll: $x).
				(String with: (Character value: 16r1F600)) }
		roundTripThrough: #String.
	self
		assertValues: {
				#[  ].
				#[ 0 255 ].
				(ByteArray new: 1000 withAll: 7) }
		roundTripThrough: #Bytes
]
