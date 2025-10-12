extends Node

const BUILDING_PRICES = {
                    "Shield":   1000,
                    "Sniper":   100,
                    "Laser":    40,
                    "Sentinel": 20,
                    "Turret":   10,
                    "Pole":     2,
                    "Sell":     0
                    }

var buildingNames:PackedStringArray

var gameTime     : float
var enemySpeed   : float
var world        : World
var maxCardLevel : int

func _ready():
    
    world = get_node("/root/World")
    enemySpeed = 1
    buildingNames = Utils.resourceNamesInDir("res://world/buildings")
    
    process_mode = PROCESS_MODE_PAUSABLE
    
    Post.subscribe(self)
    
    maxCardLevel = Card.calcMaxCardLevel()
    
func _process(delta: float):
    
    gameTime += delta
        
func startLevel():
    
    gameTime = 0.0
    
func setEnemySpeed(speed:float):

    enemySpeed = clampf(speed, 1.0, 5.0)
    Post.gameSound.emit(get_node("/root/World/Camera").followCam, "enemySpeed", enemySpeed)
    Post.enemySpeed.emit(enemySpeed)
    
func fasterEnemySpeed(): setEnemySpeed(enemySpeed + 0.5)
func slowerEnemySpeed(): setEnemySpeed(enemySpeed - 0.5)

func isUnlockedBuilding(building:String) -> bool:
    
    if Card.Unlock.has(building):
        return highscoreForCurrentLevel() >= Card.Unlock[building]
    else:
        return true

func highscoreForCurrentLevel():
    
    if world.currentLevel:
        return world.currentLevel.highscore
    
func priceForBuilding(buildingName):
    
    if BUILDING_PRICES.has(buildingName):
        return BUILDING_PRICES[buildingName]
    Log.log("PRICE FOR BUILDING?", buildingName)
    return 0

func buildingNamesSortedByPrice() -> Array:
    
    var names = Array(buildingNames)
    names.sort_custom(func(a,b): return priceForBuilding(a) > priceForBuilding(b))
    return names
    
