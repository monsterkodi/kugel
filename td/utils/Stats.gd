extends Node

var numEnemiesSpawned = 0

func _ready():
    
    Post.subscribe(self)
    
func levelStart():
    #Log.log("enemySpawned RESET")
    numEnemiesSpawned  = 0
    Post.statChanged.emit("numEnemiesSpawned",  numEnemiesSpawned)
    
func enemySpawned(spawner:Spawner):
    numEnemiesSpawned += 1
    #Log.log("enemySpawned", numEnemiesSpawned)
    Post.statChanged.emit("numEnemiesSpawned", numEnemiesSpawned)
    
