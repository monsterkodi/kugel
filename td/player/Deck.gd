class_name Deck
extends Node

var stacked = true

func clear():
    
    Utils.freeChildren(self)

func addCard(card:Card):
    
    if stacked:
        delCard(getCard(card.res.name))
    Utils.setParent(card, self)
    
func delCard(card:Card):
    
    if card and card.get_parent() == self:
        remove_child(card)
        card.free()
    
func cardLvl(cardName:String) -> int:
    
    var lvl = 0
    
    for card in get_children():
        if card.res.name == cardName: lvl += card.lvl

    return lvl
    
func getCard(cardName:String) -> Card:
    
    for card in get_children():
        if card.res.name == cardName: return card
    return null
    
func toDict() -> Dictionary:
    
    var dict = {"cards": []}
    for card in get_children():
        dict.cards.append({"card":card.res.name, "lvl":card.lvl})
    #Log.log("Deck.toDict", name, dict)
    return dict
    
func fromDict(dict:Dictionary):
    
    #Log.log("Deck.fromDict", name, dict)
    Utils.freeChildren(self)
    for cardDict in dict.cards:
        var card = Card.withName(cardDict.card)
        card.lvl = cardDict.lvl
        if card: addCard(card)
        else: Log.log("no card with name", cardDict.card)
        
func sortedCards():
    
    var cards = get_children()
    cards.sort_custom(func(a,b): return a.res.name.naturalnocasecmp_to(b.res.name) < 0)
    return cards
    
