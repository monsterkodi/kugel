class_name Deck
extends Node

func clear():
    
    Utils.freeChildren(self)

func addCard(card:Card, unique=true):
    
    if unique:
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
        dict.cards.append({"card":card.res.name, "lvl":card.lvl})
    #Log.log("Deck.toDict", dict)
    return dict
    
func fromDict(dict:Dictionary):
    
    #Log.log("Deck.fromDict", dict)
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
    
