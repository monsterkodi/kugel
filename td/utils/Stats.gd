extends Node

var numEnemiesSpawned = 0

func _ready():
    
    Post.subscribe(self)
    
func startLevel():
    #Log.log("enemySpawned RESET")
    numEnemiesSpawned  = 0
    Post.statChanged.emit("numEnemiesSpawned",  numEnemiesSpawned)
    
func enemySpawned():
    numEnemiesSpawned += 1
    #Log.log("enemySpawned", numEnemiesSpawned)
    Post.statChanged.emit("numEnemiesSpawned", numEnemiesSpawned)
    
func setNumEnemiesSpawned(num:int):
    
    numEnemiesSpawned = num
    Post.statChanged.emit("numEnemiesSpawned", numEnemiesSpawned)
    
