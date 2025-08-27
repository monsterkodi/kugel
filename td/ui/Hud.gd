extends Control

@onready var balance: Button = %Balance
@onready var spawned: Button = %Spawned
@onready var base:    Button = %Base

func _ready():
    
    Post.statChanged.connect(statChanged)
    
func statChanged(statName, value):
    Log.log("HUD.statChanged", statName, value)
    match statName:
        "balance":            balance.text = str(value)
        "baseHitPoints":      base.text    = str(value)
        "numEnemiesSpawned":  spawned.text = str(value)
