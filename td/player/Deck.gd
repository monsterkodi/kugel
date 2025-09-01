class_name Deck
extends Node

var cards:Array[Card] = []

func addCard(card:Card):
    
    #Log.log("addCard", card, card.name)
    cards.append(card)
    
func delCard(card:Card):
    
    #Log.log("delCard", card, card.name)
    assert(card in cards)
    cards.erase(card)
        
