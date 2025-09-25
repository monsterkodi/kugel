extends Node

signal enemyDied # enemy
signal enemyCorpsed # enemy
signal enemySpawned
signal corpseCollected # collector
signal buildingBought
signal buildingPlaced # building
signal buildingSold 
signal buildingGhost
signal buildingSlotChanged # slot
signal baseDamaged
signal baseDestroyed
signal shieldDamaged
signal shieldDown
signal choseCard
signal cardChosen
signal cardSold
signal applyCards
signal handChosen
signal startLevel
signal levelStart
signal levelEnd
signal levelLoaded
signal menuVanish
signal menuAppear
signal menuSound
signal gameSound
signal statChanged 
signal enemySpeed # speed
signal mainMenu
signal newGame
signal resumeGame
signal restartLevel
signal settings
signal quitGame
signal clockFactor
signal clockTick

var sigDict : Dictionary = {}

func _ready():
    
    #Log.log("the postman arrived")
    sigDict = Utils.signalDict(self)
        
func subscribe(node:Node):
    
    #Log.log(str(node.name))
    var methDict = Utils.methodDict(node)
    for sigName in sigDict:
        if methDict.has(sigName):
            #Log.log("    ", sigName)
            self.connect(sigName, node[sigName])
