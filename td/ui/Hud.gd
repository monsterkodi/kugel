class_name HUD extends Control

@onready var balance: Button = %Balance
@onready var spawned: Button = %Spawned
@onready var base:    Button = %Base
@onready var shield:  Button = %Shield

const CIRCLE = preload("uid://c2q8strea6bfu")

func _ready():
    
    shield.visible = false
    Post.statChanged.connect(statChanged)
    
func statChanged(statName, value):
    Log.log("HUD.statChanged", statName, value)
    match statName:
        "balance":            balance.text = str(value)
        "baseHitPoints":      
            base.text    = str(value)
            Utils.freeChildren(%BasePoints)
            for i in range(value):
                var circle = CIRCLE.instantiate()
                %BasePoints.add_child(circle)
                circle.diameter = 24
                circle.color = Color("9293ffff")
        "shieldHitPoints":    
            shield.visible = (value > 0)
            shield.text = "+ %d" % value 
            
            Utils.freeChildren(%ShieldPoints)
            for i in range(value):
                var circle = CIRCLE.instantiate()
                %ShieldPoints.add_child(circle)
                circle.diameter = 16
                circle.color = Color("8a75ffff")
            
        "numEnemiesSpawned":  spawned.text = str(value)
