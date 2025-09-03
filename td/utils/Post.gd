extends Node

signal enemyDied
signal enemySpawned
signal corpseCollected
signal statChanged
signal baseDestroyed
signal buildingBought
signal buildingPlaced
signal buildingGhost
signal baseDamaged
signal shieldDamaged
signal shieldDown
signal cardChosen
signal handChosen
signal startLevel
signal levelStart
signal levelEnd

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
