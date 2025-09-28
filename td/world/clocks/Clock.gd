class_name Clock
extends Node3D

@export var seconds_initial = 10.0
@export var seconds_min     = 0.2

var seconds       : float = 10.0
var pointerSecs   : float = 0.0

var pointerFactor : float = 0.0
var pointerIndex  : int   = 0
    
func _ready():
    
    process_mode = PROCESS_MODE_PAUSABLE
    set_process(false)

func save() -> Dictionary:
    
    var dict = {}
    
    dict.seconds     = seconds
    dict.pointerSecs = pointerSecs
    
    return dict
    
func load(dict:Dictionary):
    
    seconds = dict.seconds

func start():
    
    set_process(true)
    Post.subscribe(self)
    
func startLevel():
    
    seconds       = seconds_initial
    pointerSecs   = 0.0
    pointerFactor = 0
    pointerIndex  = 0
    
func _process(delta: float):
    
    pointerSecs  += delta * Info.enemySpeed
    pointerFactor = pointerSecs / seconds
    pointerIndex  = 99 - int(100 * pointerFactor)
    
    if pointerFactor >= 1.0:
        nextRound()
    
    Post.clockFactor.emit(pointerFactor)
    
func nextRound():
    
    pointerSecs   = 0.0
    pointerFactor = 0.0
    pointerIndex  = 0
    if seconds > 1.0:
        seconds *= 0.996
    else:
        seconds *= 0.999
    seconds       = maxf(seconds, seconds_min)
    
    Post.clockTick.emit()
