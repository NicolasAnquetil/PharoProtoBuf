"
Metacello baseline for PharoProtoBuf (Protocol Buffers for Pharo).
"
Class {
	#name : 'BaselineOfPharoProtoBuf',
	#superclass : 'BaselineOf',
	#category : 'BaselineOfPharoProtoBuf',
	#package : 'BaselineOfPharoProtoBuf'
}

{ #category : 'baselines' }
BaselineOfPharoProtoBuf >> baseline: spec [

	<baseline>
	spec for: #common do: [
			spec
				package: 'Protobuf-Core';
				package: 'Protobuf-Core-Tests' with: [ spec requires: #( 'Protobuf-Core' ) ].
			spec
				group: 'Core' with: #( 'Protobuf-Core' );
				group: 'Tests' with: #( 'Protobuf-Core-Tests' );
				group: 'default' with: #( 'Core' 'Tests' ) ]
]
