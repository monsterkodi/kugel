class_name CardLaser
extends Node3D

func _ready(): 

    %Laser.process_mode = Node.PROCESS_MODE_DISABLED
    %Laser.set_process(false)
    %Laser.set_physics_process(false)
    %Laser.get_node("BarrelPivot").look_at(Vector3(3, 0, 0))
