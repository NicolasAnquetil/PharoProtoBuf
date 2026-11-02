"
I am the abstract superclass of protobuf messages. Subclasses hold one instance variable per field and describe their fields on the class side with #descriptor (a PBMessageDescriptor). From that description I serialize to and parse from the protobuf wire format, using PBWireWriter and PBWireReader.
"
Class {
	#name : 'PBMessage',
	#superclass : 'Object',
	#instVars : [
		'unknownFields'
	],
	#category : 'Protobuf-Core-Runtime',
	#package : 'Protobuf-Core',
	#tag : 'Runtime'
}

{ #category : 'parsing' }
PBMessage class >> parseFrom: aByteArray [

	^ self new
		  mergeFrom: (PBWireReader on: aByteArray);
		  yourself
]

{ #category : 'parsing' }
PBMessage >> mergeFrom: aReader [
	"Read fields until aReader is at its end, setting them in me.
	Fields not in my descriptor, or arriving with an unexpected wire type, are kept as raw bytes
	and written back by #writeOn:."

	| descriptor |
	descriptor := self class descriptor.
	[ aReader atEnd ] whileFalse: [
			| mark tag field |
			mark := aReader position.
			tag := aReader readTag.
			field := descriptor fieldAt: tag fieldNumber ifAbsent: [ nil ].
			(field isNotNil and: [ field accepts: tag ])
				ifTrue: [ field read: aReader tag: tag into: self ]
				ifFalse: [
						aReader skipField: tag.
						unknownFields := (unknownFields ifNil: [ #[  ] ]) , (aReader bytesFrom: mark) ] ]
]

{ #category : 'serializing' }
PBMessage >> serialize [
	"Answer my protobuf wire-format encoding as a ByteArray."

	| writer |
	writer := PBWireWriter new.
	self writeOn: writer.
	^ writer contents
]

{ #category : 'serializing' }
PBMessage >> writeOn: aWriter [
	"Known fields in field-number order, then preserved unknown fields."

	self class descriptor fields do: [ :field |
			| value |
			value := self instVarNamed: field name.
			(value isNil or: [ field isDefault: value ]) ifFalse: [ field write: value on: aWriter ] ].
	unknownFields ifNotNil: [ aWriter writeRaw: unknownFields ]
]
