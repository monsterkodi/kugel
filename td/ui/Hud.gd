extends Control

@onready var corpses: Button = %Corpses
@onready var spawned: Button = %Spawned

func _ready():
    
    Post.statChanged.connect(statChanged)
    
func statChanged(statName, value):
    #Log.log("HUD.statChanged", statName, value)
    match statName:
        "numCorpseCollected": corpses.text = str(value)
        "numEnemiesSpawned":  spawned.text = str(value)
