
class_name Attraction extends Node3D

@export var targetPath:String = "/root/World/Level/Base"

@export_range(0.0, 100.0, 0.1) var force    = 0.0
@export_range(0.0, 100.0, 0.1) var impulse  = 5.0
@export_range(0.0, 10.0, 0.1)  var seconds  = 0.0
@export_range(0.0, 0.1, 0.01)  var distance_threshold = 0.01
@export_range(0.0, 10.0, 0.1)  var velocity_threshold = 0.1

var targetNode:Node3D

func _ready() -> void:
    
    targetNode = get_node(targetPath)
    if not targetNode:
        Log.log("Attraction - no target!", targetPath, get_path())
    
func toTarget(): return (targetNode.global_position - get_parent_node_3d().global_position)
func applyImpulse(): get_parent_node_3d().apply_central_impulse(toTarget().normalized() * impulse)
    
func _physics_process(_delta: float):
    
    if not targetNode: return
    
    if $Timer.is_stopped() and seconds > 0:
        $Timer.start(seconds)
        
    var belowThreshold = get_parent_node_3d().linear_velocity.length() <= velocity_threshold
    if velocity_threshold > 0 and impulse > 0 and belowThreshold:
        applyImpulse()
        
    if force > 0:
        if toTarget().length() > distance_threshold:
            get_parent_node_3d().apply_central_force(toTarget().normalized() * force)

func _on_timer_timeout() -> void:
    
    applyImpulse()
