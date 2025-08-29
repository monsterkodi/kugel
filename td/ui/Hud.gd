extends Control

@onready var balance: Button = %Balance
@onready var spawned: Button = %Spawned
@onready var base:    Button = %Base
@onready var shield:  Button = %Shield

func _ready():
    
    shield.visible = false
    Post.statChanged.connect(statChanged)
    
func statChanged(statName, value):
    Log.log("HUD.statChanged", statName, value)
    match statName:
        "balance":            balance.text = str(value)
        "baseHitPoints":      base.text    = str(value)
        "shieldHitPoints":    
            shield.visible = (value > 0)
            shield.text = "+ %d" % value 
        "numEnemiesSpawned":  spawned.text = str(value)
