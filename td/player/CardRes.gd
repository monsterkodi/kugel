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
@export var maxLvl:int
@export var scene:PackedScene
@export var data:Dictionary

func _to_string():   return name
func isBattleCard(): return type == CardRes.CardType.BATTLE
func isPermanent():  return type == CardRes.CardType.PERMANENT
func isTrophy():     return type == CardRes.CardType.TROPHY
func isOnce():       return type == CardRes.CardType.ONCE
