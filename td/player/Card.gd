class_name Card
extends Node

@export var res:CardRes

func setRes(cardRes:CardRes):
    
    res = cardRes
    name = res.name
