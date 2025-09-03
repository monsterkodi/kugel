class_name Card
extends Node

@export var res:CardRes

func setRes(cardRes:CardRes):
    
    res = cardRes
    name = res.name
    
func isBattleCard(): return res.type == CardRes.CardType.BATTLE
func isPermanent():  return res.type == CardRes.CardType.PERMANENT
