extends Node3D

@export var seconds_initial   = 10.0
@export var seconds_decrement = 0.008
@export var seconds_min       = 0.5

var seconds       : float = 10.0
var pointerSecs   : float = 0.0
var pointerFactor : float = 0.0
var pointerIndex  : int   = 0
var dotsActivated : int

var numSpawnerActive      = 0
var dirSign               = 1

var activeDotColor  = Color(1,0,0)
var passiveDotColor = Color(0.02,0.02,0.02)

func _ready():
    
    Post.subscribe(self)
    
func levelStart():
    
    seconds          = seconds_initial
    pointerSecs      = 0.0
    pointerFactor    = 0
    pointerIndex     = 0
    dotsActivated    = 0
    numSpawnerActive = 0
    
    %DotRing.setColor(0, activeDotColor)
    
    for i in range(1,8):
        %DotRing.setColor(i, passiveDotColor)
    
    %ClockRing.get_surface_override_material(0).set_shader_parameter("Revolution", 0.0)
    
func _process(delta: float):
    
    pointerSecs  += delta * Info.enemySpeed
    pointerFactor = pointerSecs / seconds
    pointerIndex  = 99 - int(100 * pointerFactor)
    
    if pointerFactor >= 1.0:
        nextRound()
    
    %TickRing.transform = Transform3D.IDENTITY
    %TickRing.rotate_y(pointerFactor * dirSign * PI/4.0)
        
    Post.clockFactor.emit(pointerFactor)
    
func spawnerActivated():
    
    numSpawnerActive += 1
    %DotRing.setColor(numSpawnerActive, activeDotColor)
    
func nextRound():
    
    dirSign      *= -1
    pointerSecs   = 0.0
    pointerFactor = 0.0
    pointerIndex  = 0
    seconds      -= seconds_decrement
    seconds       = maxf(seconds, seconds_min)
    
    Post.clockTick.emit()
    
func enemySpawned(s:Spawner):
    
    %ClockRing.get_surface_override_material(0).set_shader_parameter("Revolution", minf(dotsActivated/800.0, 0.999))
    
    dotsActivated += 1
