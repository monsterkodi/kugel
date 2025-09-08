extends Node

const CARD_LEVELS = [5, 5, 10, 10, 10, 20, 20, 20,
                     50, 50, 50, 50, 50, 50,        
                     50, 50, 50, 50, 50, 50,
                     100, 100, 100, 100, 100,
                     100, 100, 100, 100, 100,       # 1000    30
                     200, 200, 200, 200, 200,       # 2000
                     200, 200, 200, 200, 200,       # 3000    40
                     400, 400, 400, 400, 400,       # 5000
                     500, 500, 500, 500, 500,       # 7500    50
                     500, 500, 500, 500, 500,       # 10000 
                     500, 500, 500, 500, 500,       # 12500   60
                     500, 500, 500, 500, 500,       # 15000
                     800, 800, 800, 800, 800,       # 19000   70
                     800, 800, 800, 800, 800        # 23000
                    ]
                    
const BUILDING_PRICES = {
                    "Shield":  40,
                    "Laser":   20,
                    "Turret":  10,
                    "Bouncer": 5,
                    "Pole":    2,
                    "Sell":    0
                    }

var buildingNames:PackedStringArray

var enemySpeed:float
var player:Player

func _ready():
    
    enemySpeed = 1
    buildingNames = Utils.resourceNamesInDir("res://world/buildings")
    #Log.log("Info.buildingNames", buildingNames)
    #Log.log("Info.buildingNamesSortedByPrice", buildingNamesSortedByPrice())

func nextCardAtLevel(cardLevel:int) -> int:
    
    if cardLevel >= CARD_LEVELS.size():
        return 800
    return CARD_LEVELS[cardLevel]
    
func nextSetOfCards():
    
    Log.log("nextSetOfCards", player.cardLevel)
    
    var allCards:Array[CardRes] = Utils.allCardRes()
    var cards:Array[Card] = []
    
    if numberOfCardsOwned("Slot Ring") < 3:
        #Log.log("nextSetOfCards add Slot Ring")
        var cardRes = allCards[allCards.find_custom(func(c): return c.name == "Slot Ring")]
        allCards.erase(cardRes)
        cards.append(Card.new(cardRes))
        if numberOfCardsOwned("Slot Ring") < 1:
            cards.append(Card.new(cardRes))
            cards.append(Card.new(cardRes))
            return cards
            
    if numberOfCardsOwned("Turret") < 1:
        #Log.log("nextSetOfCards add Turret")
        var cardRes = allCards[allCards.find_custom(func(c): return c.name == "Turret")]
        allCards.erase(cardRes)
        cards.append(Card.new(cardRes))
    
    while cards.size() < 3:
        var cardRes = allCards[randi_range(0, allCards.size()-1)]
        if cardRes.maxNum > 0:
            var cardCount = numberOfCardsOwned(cardRes.name)
            if cardCount >= cardRes.maxNum:
                allCards.erase(cardRes)
                continue
        cards.append(Card.new(cardRes))
        if cardRes.maxNum > 0:
            allCards.erase(cardRes)
    return cards

func maxShieldHitPoints() -> int:
    
    return 1 + countPermCards("Shield +1")

func maxHandCards() -> int:
    
    return 1 + countPermCards("Card +1")

func countPermCards(cardName:String) -> int:
    
    return player.perm.countCards(cardName)

func countHandCards(cardName:String) -> int:
    
    return player.hand.countCards(cardName)

func countDeckCards(cardName:String) -> int:
    
    return player.deck.countCards(cardName)
    
func numberOfCardsOwned(cardName:String) -> int:
    
    return countDeckCards(cardName) + countHandCards(cardName) + countPermCards(cardName)

func priceForBuilding(buildingName):
    
    return BUILDING_PRICES[buildingName]

func buildingNamesSortedByPrice() -> Array:
    
    var names = Array(buildingNames)
    names.sort_custom(func(a,b): return priceForBuilding(a) > priceForBuilding(b))
    return names
    
func allPlacedBuildings():
    
    return get_tree().get_nodes_in_group("building")
    
func allPlacedBuildingsOfType(type):
    
    return allPlacedBuildings().filter(func(b): return b.type == type)
    
func isAnyBuildingPlaced(type):
    
    return allPlacedBuildingsOfType(type).size() > 0
    
func slotForPos(pos):
    
    var level = get_node("/root/World").currentLevel
    #var slots = level.get_tree().get_nodes_in_group("slot")
    #var slots = Utils.childrenWithClass(level, "Slot")
    var slots = Utils.filterTree(level, func(n:Node): return n is Slot)
    #Log.log("slotForPos", pos, slots)
    return Utils.closestNode(slots, pos)

    
    
