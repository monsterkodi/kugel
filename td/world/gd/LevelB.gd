class_name LevelB extends Node3D

@export var seconds_initial   = 5.0
@export var seconds_min       = 0.5

var seconds       : float = 10.0
var pointerSecs   : float = 0.0
var pointerFactor : float = 0.0

func _ready():
    
    name = "LevelB"
    add_to_group("game")
    
    Post.subscribe(self)
    
func gamePaused():
    
    set_physics_process(false)
    set_process(false)
    
func gameResumed():
    
    set_physics_process(true)
    set_process(true)

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
        
func boundsExit(body: Node3D):
    
    pass
