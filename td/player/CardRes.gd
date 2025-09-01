class_name CardRes
extends Resource

enum CardType {
    BATTLE,
    PERMANENT,
    ONCE
}

@export var name:StringName
@export var text:String
@export var scene:PackedScene
@export var maxNum:int
@export var type:CardType
