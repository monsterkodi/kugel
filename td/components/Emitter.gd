
class_name Emitter extends Node3D

@export var bullet:Resource
@export var seconds  = 0.3
@export var velocity = 20.0

var active = false
var timer  = Timer

func _ready():
    
    if not bullet: Log.log("no bullet!")
        
    timer = Timer.new()
    add_child(timer)
    timer.connect("timeout", timeout)
    
func startShooting():
    
    timer.start(seconds)
    
func stopShooting():
    
    timer.stop()

func timeout():
    
    if bullet:
        
        var instance:Node3D = bullet.instantiate()
        get_node("/root/World/Level").add_child(instance)
        instance.global_transform = global_transform
        instance.linear_velocity = global_transform.basis.z * -velocity
