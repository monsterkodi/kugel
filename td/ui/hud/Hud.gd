class_name HUD extends Control

@onready var balance: Button = %Balance
@onready var spawned: Button = %Spawned

const CIRCLE = preload("uid://c2q8strea6bfu")

func _ready():
    
    Post.subscribe(self)
    
func statChanged(statName, value):

    match statName:
        
        "balance":            
            
            balance.text = str(value)
            
        "baseHitPoints":      
            
            Utils.freeChildren(%BasePoints)
            for i in range(value):
                var circle = CIRCLE.instantiate()
                %BasePoints.add_child(circle)
                circle.diameter = 24
                circle.color = Color("9293ffff")
                
        "shieldHitPoints":    
            
            Utils.freeChildren(%ShieldPoints)
            for i in range(value):
                var circle = CIRCLE.instantiate()
                %ShieldPoints.add_child(circle)
                circle.diameter = 16
                circle.color = Color("8a75ffff")
            
        "numEnemiesSpawned":  
            
            spawned.text = str(value)
