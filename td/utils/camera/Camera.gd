extends Node3D

func _ready() -> void:
    
    %Follow.target  = %Player
    %Follow.current = true
    
func toggleFreeFlight():
    
    if %Follow.current:
        %FreeFlight.current = true
    else:
        %Follow.current = true

func on_save(data:Dictionary):

    data.Camera = {}
    data.Camera.freeflight_transform = %FreeFlight.transform
    data.Camera.transform   = transform
    data.Camera.follow_dist = %Follow.dist
    
func on_load(data:Dictionary):

    transform = data.Camera.transform
    %FreeFlight.transform = data.Camera.freeflight_transform
    %Follow.dist = data.Camera.follow_dist
