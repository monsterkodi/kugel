class_name CardSetup
extends Node3D

@export var cameraOffset:Vector2:
    set(v): 
        cameraOffset = v
        if is_inside_tree():
            get_node("../../Camera").h_offset = v.x
            get_node("../../Camera").v_offset = v.y

@export_range(0.1, 10.0) var cameraDistance:float = 1.0:
    set(v): 
        cameraDistance = v
        if is_inside_tree():
            get_node("../../Camera").global_position = Vector3(0,3,3)*v

@export_range(10.0, 90.0) var cameraFov:float = 45.0:
    set(v): 
        cameraFov = v
        if is_inside_tree():
            get_node("../../Camera").fov = v

func _ready():
    
    cameraOffset   = cameraOffset
    cameraDistance = cameraDistance
    cameraFov      = cameraFov
    
