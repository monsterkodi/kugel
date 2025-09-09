class_name CardTurret
extends Node3D

func _ready(): 

    %Turret.inert = true
    %Turret.set_process(false)
    %Turret.set_physics_process(false)
    %Turret.get_node("BarrelPivot").look_at(Vector3(3, 0, 0))
