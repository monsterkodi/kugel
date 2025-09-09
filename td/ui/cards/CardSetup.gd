class_name CardSetup
extends Node3D

@export var cameraOffset:Vector2 = Vector2.ZERO:
    set(v): 
        cameraOffset = v
        updateCamera()

@export_range(0.1, 20.0) var cameraDistance:float = 3.0:
    set(v): 
        cameraDistance = v
        updateCamera()

@export_range(10.0, 90.0) var cameraFov:float = 45.0:
    set(v): 
        cameraFov = v
        updateCamera()            
            
@export_range(0.01, 10.0) var cameraTargetY: float = 1.0:  
    set(v):
        cameraTargetY = v
        updateCamera()          
        
@export_range(0.01, 10.0) var cameraHeight: float = 3.0:            
    set(v):
        cameraHeight = v
        updateCamera()          

func _ready():
    
    updateCamera()

func updateCamera():
    
    if is_inside_tree():
        
        var camera = get_node("../../Camera")
        camera.fov = cameraFov
        camera.h_offset = cameraOffset.x
        camera.v_offset = cameraOffset.y
        camera.global_position = Vector3(0,cameraHeight,cameraDistance)
        camera.look_at(Vector3(0,cameraTargetY,0), Vector3.UP)

    
