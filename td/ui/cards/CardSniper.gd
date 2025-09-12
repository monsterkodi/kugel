class_name CardSniper
extends Node3D

@export var lookAt:Vector3:
    set(v): 
        lookAt = v
        if is_inside_tree():
            %Sniper.get_node("BarrelPivot").look_at(v)

func _ready(): 

    %Sniper.inert = true
    %Sniper.set_process(false)
    %Sniper.set_physics_process(false)
    lookAt = lookAt
