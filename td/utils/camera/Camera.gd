extends Node3D

@onready var followCam:  Camera3D = %FollowCam
@onready var freeFlight: Camera3D = %FreeFlight

func _ready():
    
    followCam.target  = %Player
    followCam.current = true
    
func followCameraPosition():
    
    return followCam.global_position
    
func toggleFreeFlight():
    
    if followCam.current:
        freeFlight.current = true
    else:
        followCam.current = true

func on_save(data:Dictionary):

    data.Camera = {}
    data.Camera.freeflight_transform = freeFlight.transform
    data.Camera.transform   = transform
    data.Camera.follow_dist = followCam.dist
    
func on_load(data:Dictionary):

    if data.has("Camera"):
        transform = data.Camera.transform
        freeFlight.transform = data.Camera.freeflight_transform
        followCam.dist = data.Camera.follow_dist
