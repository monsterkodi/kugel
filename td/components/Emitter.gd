class_name Emitter 
extends Node3D

@export var bullet:Resource

var delay     = 0.0
var interval  = 1.0
var velocity  = 20.0
var mass      = 1.0

signal shotFired

var delayTimer:Timer
var shootTimer:Timer

var world : World

func _ready():
    
    world = get_node("/root/World")
    
    if not bullet: Log.log("no bullet!")
        
    delayTimer = Timer.new()
    shootTimer = Timer.new()
    add_child(delayTimer)
    add_child(shootTimer)
    delayTimer.one_shot = true
    shootTimer.one_shot = false
    delayTimer.connect("timeout", startShooting)
    shootTimer.connect("timeout", shoot)
    
func start():
    
    if shootTimer.is_stopped() and delayTimer.is_stopped():
        delayTimer.start(delay)
    
func stop():
    
    delayTimer.stop()
    shootTimer.stop()
    
func startShooting():
    
    shootTimer.start(interval)
    shoot()
    
func shoot():
    
    if bullet:
        
        var instance:Node3D = bullet.instantiate()
        world.currentLevel.get_node("Bullets").add_child(instance)
        instance.mass = mass
        instance.global_transform = global_transform
        instance.linear_velocity = global_transform.basis.z * -velocity
        shotFired.emit()
        %fire.play()
