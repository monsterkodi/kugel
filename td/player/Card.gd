class_name Card
extends Node

var res:CardRes

func _init(cardRes:CardRes):
    
    res = cardRes
    
func _to_string():   return res.name
    
func isBattleCard(): return res.type == CardRes.CardType.BATTLE
func isPermanent():  return res.type == CardRes.CardType.PERMANENT
func isOnce():       return res.type == CardRes.CardType.ONCE
