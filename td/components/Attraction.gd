
class_name Attraction extends Node3D

@export var targetPath:String = ""
@export var targetPoint:Vector3 = Vector3.ZERO

@export_range(0.0, 10000.0)    var force    = 0.0
@export_range(0.0, 100.0, 0.1) var impulse  = 5.0
@export_range(0.0, 10.0, 0.1)  var seconds  = 0.0
@export_range(0.0, 0.1, 0.01)  var distance_threshold = 0.01
@export_range(0.0, 10.0, 0.1)  var velocity_threshold = 0.1

var targetNode:Node3D

func _ready():
    
    if not targetPath.is_empty():
        targetNode = get_node(targetPath)

func disable():
    
    set_process(false)
    set_physics_process(false)
    
func targetPos(): 
    if targetNode: 
        return targetNode.global_position
    return targetPoint
    
func toTarget(): return (targetPos() - get_parent_node_3d().global_position)
func applyImpulse(): get_parent_node_3d().apply_central_impulse(toTarget().normalized() * impulse * get_parent_node_3d().mass)
    
func _physics_process(_delta: float):
    
    #if not targetNode: return
    
    if $Timer.is_stopped() and seconds > 0:
        $Timer.start(seconds)
    
    if velocity_threshold > 0 and impulse > 0:
        if get_parent_node_3d().linear_velocity.length() <= velocity_threshold:
            applyImpulse()
        
    if force > 0:
        if toTarget().length() > distance_threshold:
            #get_parent_node_3d().apply_central_force(toTarget().normalized() * force)
            get_parent_node_3d().apply_central_force(toTarget() * force)

func _on_timer_timeout():
    
    applyImpulse()
