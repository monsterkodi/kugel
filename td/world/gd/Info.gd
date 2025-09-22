extends Node

const BUILDING_PRICES = {
                    "Shield":  1000,
                    "Sniper":  100,
                    "Laser":   40,
                    "Bouncer": 20,
                    "Turret":  10,
                    "Pole":    2,
                    "Sell":    0
                    }

var buildingNames:PackedStringArray

var wallTime     : float
var gameTime     : float
var enemySpeed   : float
var player       : Player
var world        : World
var maxCardLevel : int

func _ready():
    
    world = get_node("/root/World")
    enemySpeed = 1
    buildingNames = Utils.resourceNamesInDir("res://world/buildings")
    
    process_mode = PROCESS_MODE_PAUSABLE
    
    Post.subscribe(self)
    
    maxCardLevel = Card.calcMaxCardLevel()
    #Log.log("maxCardLevel", maxCardLevel)
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

func isUnlockedBuilding(building:String) -> bool:
    
    if Card.Unlock.has(building):
        return highscoreForCurrentLevel() >= Card.Unlock[building]
    else:
        return true

func isUnlockedCard(cardName:String) -> bool:

    if Card.Unlock.has(cardName):
        return highscoreForCurrentLevel() >= Card.Unlock[cardName]
    else:
        return true

func isLockedCard(cardName:String) -> bool:

    if Card.Unlock.has(cardName):
        return highscoreForCurrentLevel() < Card.Unlock[cardName]
    else:
        return false

func nextCardAtLevel(cardLevel:int) -> int:

    #Log.log("cardLevel", cardLevel, (cardLevel+1) * 5)
    return (cardLevel+1) * 5 
    
func highscoreForCurrentLevel():
    
    return world.currentLevel.highscore
    
func nextSetOfCards():
    
    var allCards:Array[CardRes] = Card.allRes()
    var cards:Array[Card] = []
    
    if numberOfCardsOwned(Card.SlotRing) < 3 and isUnlockedCard(Card.SlotRing):
        #Log.log("nextSetOfCards add Slot Ring")
        var cardRes = allCards[allCards.find_custom(func(c): return c.name == Card.SlotRing)]
        allCards.erase(cardRes)
        cards.append(Card.new(cardRes))
            
    if numberOfCardsOwned(Card.Turret) < 1:
        var cardRes = allCards[allCards.find_custom(func(c): return c.name == Card.Turret)]
        allCards.erase(cardRes)
        cards.append(Card.new(cardRes))

    if numberOfCardsOwned(Card.Laser) < 1 and (player.cardLevel % 10) == 0:
        var cardRes = allCards[allCards.find_custom(func(c): return c.name == Card.Laser)]
        allCards.erase(cardRes)
        cards.append(Card.new(cardRes))

    if numberOfCardsOwned(Card.Sniper) < 1 and (player.cardLevel % 20) == 0:
        var cardRes = allCards[allCards.find_custom(func(c): return c.name == Card.Sniper)]
        allCards.erase(cardRes)
        cards.append(Card.new(cardRes))
    
    while cards.size() < 3:
        
        if allCards.is_empty():
            cards.append(Card.withName(Card.Money))
            continue
        
        assert(not allCards.is_empty())
        var cardRes = allCards[randi_range(0, allCards.size()-1)]
        if cardRes.maxNum > 0:
            var cardCount = numberOfCardsOwned(cardRes.name)
            if cardCount >= cardRes.maxNum:
                allCards.erase(cardRes)
                continue
        if cardRes.type == CardRes.CardType.TROPHY or isLockedCard(cardRes.name):
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
    
