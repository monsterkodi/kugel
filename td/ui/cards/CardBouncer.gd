class_name CardBouncer
extends Node3D

func _ready(): 

    %Bouncer.inert = true
    %Bouncer.set_process(false)
    %Bouncer.set_physics_process(false)
    %Bouncer.setSensorRadius(0)
