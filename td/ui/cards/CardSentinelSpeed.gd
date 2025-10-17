class_name CardSentinelSpeed
extends Node3D

func _ready(): 

    %Sentinel1.set_process(false)
    %Sentinel1.set_physics_process(false)
    %Sentinel1.setSensorRadius(3)

    %Sentinel2.set_process(false)
    %Sentinel2.set_physics_process(false)
    %Sentinel2.setSensorRadius(3)

    %Sentinel3.set_process(false)
    %Sentinel3.set_physics_process(false)
    %Sentinel3.setSensorRadius(3)
