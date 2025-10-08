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
signal preChooseAnim
signal chooseCard
signal cardChosen
signal cardSold
signal applyCards
signal handChosen
signal gamePaused
signal gameResume
signal startLevel
signal retryLevel
signal levelStart
signal levelReset
signal levelEnd
signal levelLoaded
signal levelSaved
signal mainMenu
signal menuVanish
signal menuAppear
signal menuDidAppear
signal menuSound
signal gameSound
signal statChanged 
signal enemySpeed # speed
signal newGame
signal resumeGame
signal restartLevel
signal settings
signal quitGame
signal clockFactor
signal clockTick

var sigDict : Dictionary

func _ready():
    
    sigDict = Utils.signalDict(self)
        
func subscribe(node:Node):
    
    var methDict = Utils.methodDict(node)
    for sigName in sigDict:
        if methDict.has(sigName):
            self.connect(sigName, node[sigName])
