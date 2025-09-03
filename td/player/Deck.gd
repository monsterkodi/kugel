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
        
func toDict() -> Dictionary:
    
    var dict = {"cards": []}
    for card in cards:
        dict.cards.append(card.name)
    return dict
    
func fromDict(dict:Dictionary):
    
    cards = []
    for cardName in dict.cards:
        var card = Utils.cardWithName(cardName)
        if card: addCard(card)
        else: Log.log("no card with name", cardName)
    
    
    
