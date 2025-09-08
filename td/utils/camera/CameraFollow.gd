extends Camera3D

@export var target:Node3D

var MIN_PITCH  := 20.0
var MAX_PITCH  := 80.0
var MIN_TAIL   := 5.0
var MAX_TAIL   := 25.0
var MIN_ALTI   := 2.5
var MAX_ALTI   := 5.5
var ZOOM_SPEED := 0.5
var INTERPOL   := 0.9

var dist  := 0.5
var tail  := 5.0
var alti  := 2.5
var pitch := 45.0
var zoom  := 0.0

func _ready():

    translate_object_local(Vector3.FORWARD * -tail)
    translate_object_local(Vector3.UP * alti)

func _physics_process(delta:float):
    
    if not current: return
    if not target:  Log.warn("no target!"); return
    
    readInput()
    
    var pt = get_parent_node_3d()
    pt.transform = target.transform.interpolate_with(pt.transform, INTERPOL)
    
    dist += zoom * ZOOM_SPEED * delta 
    dist = clampf(dist, 0, 1)
    
    alti  = lerpf(MIN_ALTI,  MAX_ALTI,  dist)
    tail  = lerpf(MIN_TAIL,  MAX_TAIL,  dist)
    pitch = lerpf(MIN_PITCH, MAX_PITCH, dist)
    
    transform = Transform3D.IDENTITY
    rotate_object_local(Vector3.RIGHT, -deg_to_rad(pitch))
    translate_object_local(Vector3.FORWARD * -tail)
    global_translate(Vector3.UP * alti)

func readInput():
    
    zoom = 0
    
    zoom = Input.get_joy_axis(0, JOY_AXIS_RIGHT_Y)
    #if not get_tree().paused:
    if Input.is_action_pressed("ascend"):  zoom -= 1
    if Input.is_action_pressed("descend"): zoom += 1
