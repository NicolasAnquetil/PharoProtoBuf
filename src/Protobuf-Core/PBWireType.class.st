"
I name the protobuf wire types: VARINT 0, I64 1, LEN 2, SGROUP 3, EGROUP 4, I32 5.
"
Class {
	#name : 'PBWireType',
	#superclass : 'Object',
	#category : 'Protobuf-Core-Wire',
	#package : 'Protobuf-Core',
	#tag : 'Wire'
}

{ #category : 'constants' }
PBWireType class >> egroup [

	^ 4
]

{ #category : 'constants' }
PBWireType class >> i32 [

	^ 5
]

{ #category : 'constants' }
PBWireType class >> i64 [

	^ 1
]

{ #category : 'constants' }
PBWireType class >> len [

	^ 2
]

{ #category : 'constants' }
PBWireType class >> sgroup [

	^ 3
]

{ #category : 'constants' }
PBWireType class >> varint [

	^ 0
]
