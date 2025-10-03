class_name HUD 
extends Control

@onready var balance: Button = %Balance
@onready var spawned: Button = %Spawned

static var showClock : bool = true

const CIRCLE = preload("uid://c2q8strea6bfu")

func _ready():
    
    Post.subscribe(self)
    
    process_mode = Node.PROCESS_MODE_PAUSABLE
    
func _process(delta: float):
    
    %Clock.text = Utils.timeStr(Info.gameTime)
    %ClockPanel.visible = HUD.showClock
    
func enemySpeed(speed):
    
    %EnemySpeed.value = speed
    
func statChanged(statName, value):

    match statName:
        
        "balance":           balance.text = str(value)
        "numEnemiesSpawned": spawned.text = str(value)
        "baseHitPoints":     setBasePoints(value)     
        "shieldHitPoints":   setShieldPoints(value)

func setBasePoints(value):
    
    Utils.freeChildren(%BasePoints)
    for i in range(value):
        var circle = CIRCLE.instantiate()
        %BasePoints.add_child(circle)
        circle.diameter = 24
        circle.color = Color("9293ffff")

func setShieldPoints(value):
    
    Utils.freeChildren(%ShieldPoints)
    for i in range(value):
        var circle = CIRCLE.instantiate()
        %ShieldPoints.add_child(circle)
        circle.diameter = 16
        circle.color = Color("8a75ffff")
