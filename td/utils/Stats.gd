extends Node

var numEnemiesSpawned = 0

func _ready():
    
    Post.enemySpawned.connect(enemySpawned)
    Post.baseDestroyed.connect(baseDestroyed)
    
func baseDestroyed():
    
    numEnemiesSpawned  = 0
    
    Post.statChanged.emit("numEnemiesSpawned",  numEnemiesSpawned)

func enemySpawned():
    
    numEnemiesSpawned += 1
    Post.statChanged.emit("numEnemiesSpawned", numEnemiesSpawned)
    
