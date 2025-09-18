class_name LevelB 
extends Level

@export var seconds_initial   = 5.0
@export var seconds_min       = 0.5

var seconds       : float = 10.0
var pointerSecs   : float = 0.0
var pointerFactor : float = 0.0

func applyCards(): pass
    
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
