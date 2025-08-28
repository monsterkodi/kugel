extends Node3D

func _ready() -> void:
    
    %Follow.target  = %Player
    %Follow.current = true
    
#func _input(event: InputEvent):
    #
    #if event.is_action_pressed("alt_left"):
        #toggleFreeFlight()
        
func toggleFreeFlight():
    
    if %Follow.current:
        %FreeFlight.current = true
        get_tree().call_group("player", "input_disable")
    else:
        %Follow.current = true
        get_tree().call_group("player", "input_enable")

func on_save(data:Dictionary):

    data.Camera = {}
    data.Camera.freeflight_transform = %FreeFlight.transform
    data.Camera.transform   = transform
    data.Camera.follow_dist = %Follow.dist
    
func on_load(data:Dictionary):

    transform = data.Camera.transform
    %FreeFlight.transform = data.Camera.freeflight_transform
    %Follow.dist = data.Camera.follow_dist
