class_name Cards
extends Node3D

var deck   : Deck
var hand   : Deck
var perm   : Deck
var battle : Deck

var nextCardIn  : int
var cardLevel   : int

func _ready():
    
    deck   = Deck.new(); deck  .name = "deck"
    hand   = Deck.new(); hand  .name = "hand"
    perm   = Deck.new(); perm  .name = "perm"
    battle = Deck.new(); battle.name = "battle"
    
    hand.stacked   = false
    battle.stacked = false
    
    add_child(deck)
    add_child(hand)
    add_child(perm)
    add_child(battle)
    
    reset()

func reset():
    
    cardLevel  = 0
    nextCardIn = 5

    deck  .clear()
    hand  .clear()
    perm  .clear()
    battle.clear()
    
    perm.addCard(Card.withName(Card.BattleCard))
    
func save() -> Dictionary:
    
    var dict = {}
    
    dict.hand              = hand.toDict()
    dict.deck              = deck.toDict()
    dict.perm              = perm.toDict()
    dict.battle            = battle.toDict()
    dict.nextCardIn        = nextCardIn
    dict.cardLevel         = cardLevel
    
    return dict
    
func load(dict:Dictionary):
    
    cardLevel  = maxi(dict.cardLevel, 0)
    nextCardIn = clampi(dict.nextCardIn, 1, nextCardAtLevel())
    
    hand.fromDict(dict.hand)
    deck.fromDict(dict.deck)
    perm.fromDict(dict.perm)
    battle.fromDict(dict.battle)
    
    if perm.get_child_count() == 0:
        perm.addCard(Card.withName(Card.BattleCard))
     
func nextCardAtLevel()        -> int: return (cardLevel+1) * 5 
func maxShieldHitPoints()     -> int: return 1 + permLvl(Card.ShieldLayer)
func battleCardSlots()        -> int: return permLvl(Card.BattleCard)
func permLvl(cardName:String) -> int: return perm.cardLvl(cardName)
func deckLvl(cardName:String) -> int: return deck.cardLvl(cardName)
func handLvl(cardName:String) -> int: return hand.cardLvl(cardName)
func cardLvl(cardName:String) -> int: return deckLvl(cardName) + permLvl(cardName) + handLvl(cardName)    

func isUnlockedCard(cardName:String) -> bool:

    if Card.Unlock.has(cardName):
        return Info.highscoreForCurrentLevel() >= Card.Unlock[cardName]
    else:
        return true

func isLockedCard(cardName:String) -> bool:

    if Card.Unlock.has(cardName):
        return Info.highscoreForCurrentLevel() < Card.Unlock[cardName]
    else:
        return false

func nextSetOfCards():
    
    var allCards:Array[CardRes] = Card.allRes()
    var cards:Array[Card] = []

    #var moneyRes = allCards[allCards.find_custom(func(c): return c.name == Card.Money)]
    #allCards.erase(moneyRes)
    #cards.append(Card.new(moneyRes))
    
    if cardLvl(Card.SlotRing) < 3 and isUnlockedCard(Card.SlotRing):
        var cardRes = allCards[allCards.find_custom(func(c): return c.name == Card.SlotRing)]
        allCards.erase(cardRes)
        cards.append(Card.new(cardRes, cardLvl(Card.SlotRing)+1))
            
    while cards.size() < 3:
        
        if allCards.is_empty():
            cards.append(Card.withName(Card.Money))
        else:
            var cardRes = allCards[randi_range(0, allCards.size()-1)]
            allCards.erase(cardRes)
            if cardRes.maxLvl > 0:
                if cardLvl(cardRes.name) >= cardRes.maxLvl:
                    continue
            if cardRes.name == Card.ShieldLayer and cardLvl(Card.Shield) == 0:
                continue
            if cardRes.type == CardRes.CardType.TROPHY or isLockedCard(cardRes.name):
                continue
            cards.append(Card.new(cardRes, cardLvl(cardRes.name)+1))
            
    return cards
