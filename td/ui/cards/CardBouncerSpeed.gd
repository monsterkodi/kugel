class_name CardBouncerSpeed
extends Node3D

func _ready(): 

    %Bouncer1.inert = true
    %Bouncer1.set_process(false)
    %Bouncer1.set_physics_process(false)
    %Bouncer1.setSensorRadius(3)

    %Bouncer2.inert = true
    %Bouncer2.set_process(false)
    %Bouncer2.set_physics_process(false)
    %Bouncer2.setSensorRadius(3)

    %Bouncer3.inert = true
    %Bouncer3.set_process(false)
    %Bouncer3.set_physics_process(false)
    %Bouncer3.setSensorRadius(3)
