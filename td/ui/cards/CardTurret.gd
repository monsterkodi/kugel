class_name CardTurret
extends Node3D

@export var lookAt:Vector3:
    set(v): 
        lookAt = v
        if is_inside_tree():
            %Turret.get_node("BarrelPivot").look_at(v)
            
func _ready(): 

    %Turret.set_process(false)
    %Turret.set_physics_process(false)
    lookAt = lookAt
