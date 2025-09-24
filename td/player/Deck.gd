class_name Deck
extends Node

func addCard(card:Card):
    
    delCard(getCard(card.res.name))
    Utils.setParent(card, self)
    
func delCard(card:Card):
    
    if card and card.get_parent() == self:
        remove_child(card)
        card.free()
    
func cardLvl(cardName:String) -> int:
    
    for card in get_children():
        if card.res.name == cardName: return card.lvl
    return 0
    
func getCard(cardName:String) -> Card:
    
    for card in get_children():
        if card.res.name == cardName: return card
    return null
    
func toDict() -> Dictionary:
    
    var dict = {"cards": []}
    for card in get_children():
        dict.cards.append(card.res.name)
    #Log.log("Deck.toDict", dict)
    return dict
    
func fromDict(dict:Dictionary):
    
    #Log.log("Deck.fromDict", dict)
    Utils.freeChildren(self)
    for cardName in dict.cards:
        var card = Card.withName(cardName)
        if card: addCard(card)
        else: Log.log("no card with name", cardName)
        
func sortedCards():
    
    var cards = get_children()
    cards.sort_custom(func(a,b): return a.res.name.naturalnocasecmp_to(b.res.name) < 0)
    return cards
    
