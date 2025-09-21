class_name CardRes
extends Resource

enum CardType {
    BATTLE,
    PERMANENT,
    TROPHY,
    ONCE
}

@export var name:StringName
@export var type:CardType
@export var text:String
@export var maxNum:int
@export var scene:PackedScene
@export var data:Dictionary
