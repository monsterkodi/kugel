class_name Deck
extends RefCounted

var cards:Array[Card] = []

func addCard(card:Card):
    
    Log.log("addCard", card, card.name)
    cards.append(card)
    Log.log("cards", cards)
    
func delCard(card:Card):
    
    Log.log("delCard", card, card.name)
    assert(card in cards)
    cards.erase(card)
        
