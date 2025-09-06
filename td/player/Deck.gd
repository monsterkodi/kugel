class_name Deck
extends Node

func addCard(card:Card):
    
    #Log.log("addCard", card, card.res.name)
    Utils.setParent(card, self)
    
func countCards(cardName:String) -> int:
    
    var num = 0
    for card in get_children():
        if card.res.name == cardName: num += 1
    return num
    
func toDict() -> Dictionary:
    
    var dict = {"cards": []}
    for card in get_children():
        dict.cards.append(card.res.name)
    Log.log("Deck.toDict", dict)
    return dict
    
func fromDict(dict:Dictionary):
    
    Log.log("Deck.fromDict", dict)
    Utils.freeChildren(self)
    for cardName in dict.cards:
        var card = Utils.newCardWithName(cardName)
        if card: addCard(card)
        else: Log.log("no card with name", cardName)
        
func sortedCards():
    
    var cards = get_children()
    cards.sort_custom(func(a,b): return a.res.name > b.res.name)
    return cards
    
    
    
