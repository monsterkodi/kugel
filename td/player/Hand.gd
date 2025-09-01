class_name Hand
extends RefCounted

var cards:Array[Card] = []

func addCard(card:Card):
    
    cards.append(card)
    
func delCard(card:Card):
    
    cards.erase(card)
