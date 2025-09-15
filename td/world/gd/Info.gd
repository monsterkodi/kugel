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
                    "Shield":  500,
                    "Sniper":  100,
                    "Laser":   40,
                    "Turret":  20,
                    "Bouncer": 10,
                    "Pole":    2,
                    "Sell":    0
                    }

var buildingNames:PackedStringArray

var wallTime    : float
var gameTime    : float
var enemySpeed  : float
var player      : Player
var world       : World

func _ready():
    
    world = get_node("/root/World")
    enemySpeed = 1
    buildingNames = Utils.resourceNamesInDir("res://world/buildings")
    
    process_mode = PROCESS_MODE_PAUSABLE
    
    Post.subscribe(self)
    #Log.log("Info.buildingNames", buildingNames)
    #Log.log("Info.buildingNamesSortedByPrice", buildingNamesSortedByPrice())
    
func _process(delta: float):
    
    wallTime += delta / Engine.time_scale
    gameTime += delta
        
func levelStart():
    
    wallTime = 0.0
    gameTime = 0.0
    
func setEnemySpeed(speed:float):

    enemySpeed = clampf(speed, 1.0, 5.0)
    Post.enemySpeed.emit(enemySpeed)
    
func fasterEnemySpeed(): setEnemySpeed(enemySpeed + 0.5)
func slowerEnemySpeed(): setEnemySpeed(enemySpeed - 0.5)

func nextCardAtLevel(cardLevel:int) -> int:
    
    if cardLevel >= CARD_LEVELS.size():
        return 800
    return CARD_LEVELS[cardLevel]
    
func nextSetOfCards():
    
    #Log.log("nextSetOfCards", player.cardLevel)
    
    var allCards:Array[CardRes] = Card.allRes()
    var cards:Array[Card] = []
    #for c in allCards: Log.log(c.name)
    if numberOfCardsOwned(Card.SlotRing) < 3:
        #Log.log("nextSetOfCards add Slot Ring")
        var cardRes = allCards[allCards.find_custom(func(c): return c.name == Card.SlotRing)]
        allCards.erase(cardRes)
        cards.append(Card.new(cardRes))
        #if numberOfCardsOwned(Card.SlotRing) < 1:
            #cards.append(Card.new(cardRes))
            #cards.append(Card.new(cardRes))
            #return cards
            
    if numberOfCardsOwned(Card.Turret) < 1:
        #Log.log("nextSetOfCards add Turret")
        var cardRes = allCards[allCards.find_custom(func(c): return c.name == Card.Turret)]
        allCards.erase(cardRes)
        cards.append(Card.new(cardRes))

    if numberOfCardsOwned(Card.Laser) < 1 and (player.cardLevel % 10) == 0:
        #Log.log("nextSetOfCards add Turret")
        var cardRes = allCards[allCards.find_custom(func(c): return c.name == Card.Laser)]
        allCards.erase(cardRes)
        cards.append(Card.new(cardRes))

    if numberOfCardsOwned(Card.Sniper) < 1 and (player.cardLevel % 20) == 0:
        #Log.log("nextSetOfCards add Turret")
        var cardRes = allCards[allCards.find_custom(func(c): return c.name == Card.Laser)]
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
    
    return 1 + countPermCards(Card.ShieldLayer)

func battleCardSlots() -> int:
    
    return countPermCards(Card.BattleCard)

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
    
    var level = world.currentLevel
    var slots = Utils.filterTree(level, func(n:Node): return n is Slot)
    return Utils.closestNode(slots, pos)
