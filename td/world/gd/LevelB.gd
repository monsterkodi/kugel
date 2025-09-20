class_name LevelLinea 
extends Level

@export var seconds_initial   = 5.0
@export var seconds_min       = 0.5

var seconds       : float = 10.0
var pointerSecs   : float = 0.0
var pointerFactor : float = 0.0

func _ready():
    
    super._ready()
    name = "Linea"

func applyCards():
    
    var rings = Info.countPermCards(Card.SlotRing)
    %SlotRing1.visible = true
    %SlotRing2.visible = (rings >= 1)
    %SlotRing3.visible = (rings >= 2)
    %SlotRing4.visible = (rings >= 3)
    %SlotRing5.visible = (rings >= 4)
    %SlotRing6.visible = (rings >= 5)
        
func _process(delta: float):
    
    pointerSecs  += delta * Info.enemySpeed
    pointerFactor = pointerSecs / seconds
    
    if pointerFactor >= 1.0:
        nextRound()
    
    Post.clockFactor.emit(pointerFactor)

func nextRound():
    
    pointerSecs   = 0.0
    pointerFactor = 0.0
    if seconds > 1.0:
        seconds *= 0.996
    else:
        seconds *= 0.999
    seconds       = maxf(seconds, seconds_min)
    
    Post.clockTick.emit()
