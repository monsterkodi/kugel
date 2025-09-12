extends Node3D

@export var seconds_initial   = 10.0
@export var seconds_decrement = 0.02
@export var seconds_min       = 1.0

var seconds       : float = 10.0
var pointerSecs   : float = 0.0
var pointerFactor : float = 0.0
var pointerIndex  : int   = 0
var numSpawnerActive = 0
var dotsActivated : int
var dirSign       = 1

func _ready():
    
    Post.subscribe(self)
    
func levelStart():
    
    seconds       = seconds_initial
    pointerSecs   = 0.0
    pointerFactor = 0
    pointerIndex  = 0
    dotsActivated = 0
    
    %DotRing.setColor(0, Color(0.26,0,0))
    for i in range(1,8):
        %DotRing.setColor(i, Color(0.02,0.02,0.02))
    
    for child in %DotRing2.get_children():
        child.color = Color(0.02,0.02,0.02)
    
func _process(delta: float):
    
    pointerSecs  += delta * Info.enemySpeed
    pointerFactor = pointerSecs / seconds
    pointerIndex  = 99 - int(100 * pointerFactor)
    
    if pointerFactor >= 1.0:
        nextRound()
    
    %DotRing3.transform = Transform3D.IDENTITY
    %DotRing3.rotate_y(pointerFactor * dirSign * PI/4.0)
        
    Post.clockFactor.emit(pointerFactor)
    
func spawnerActivated():
    
    numSpawnerActive += 1
    %DotRing.setColor(numSpawnerActive, Color(0.26,0,0))
    
func nextRound():
    
    dirSign      *= -1
    pointerSecs   = 0.0
    pointerFactor = 0.0
    pointerIndex  = 0
    seconds      -= seconds_decrement
    seconds       = maxf(seconds, seconds_min)
    
    Post.clockTick.emit()
    
func enemySpawned(s:Spawner):
    
    %DotRing2.setColor(dotsActivated, Color(2,0,0))
    
    dotsActivated += 1
