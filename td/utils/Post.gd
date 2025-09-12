extends Node

signal enemyDied # enemy
signal enemySpawned # spawner
signal corpseCollected # collector
signal buildingBought
signal buildingPlaced # building
signal buildingGhost
signal baseDamaged
signal baseDestroyed
signal shieldDamaged
signal shieldDown
signal cardChosen
signal applyCards
signal handChosen
signal startLevel
signal levelStart
signal levelEnd
signal menuVanish
signal menuAppear
signal menuSound
signal gameSound
signal statChanged 
signal newGame
signal resumeGame
signal restartLevel
signal settings
signal quitGame
signal clockFactor
signal clockTick

var sigDict:Dictionary

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
