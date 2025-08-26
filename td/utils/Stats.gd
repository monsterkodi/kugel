extends Node

var numCorpseCollected = 0
var numEnemiesSpawned  = 0

func _ready():
    
    Post.corpseCollected.connect(corpseCollected)
    Post.enemySpawned.connect(enemySpawned)
    Post.baseDestroyed.connect(baseDestroyed)
    
func baseDestroyed():
    
    numCorpseCollected = 0
    numEnemiesSpawned  = 0
    
    Post.statChanged.emit("numCorpseCollected", numCorpseCollected)
    Post.statChanged.emit("numEnemiesSpawned",  numEnemiesSpawned)

func corpseCollected():
    
    numCorpseCollected += 1
    Post.statChanged.emit("numCorpseCollected", numCorpseCollected)

func enemySpawned():
    
    numEnemiesSpawned += 1
    Post.statChanged.emit("numEnemiesSpawned", numEnemiesSpawned)
    
