class_name SniperRay extends Node3D

@export var radius = 0.5:
    set(v): radius = v; update()
@export var range  = 100.0:
    set(v): range = v; update()

@export var material:Material = preload("uid://4lqcupd84lbp")

var cylinder : MeshInstance3D

func _ready():
    
    cylinder = MeshInstance3D.new()
    cylinder.mesh = CylinderMesh.new()
    cylinder.rotation.x = deg_to_rad(-90)
    cylinder.set_surface_override_material(0, material)

    add_child(cylinder)
    update()
    
func shoot():
    
    visible = true
    
    var secs = 0.5
    var tween = create_tween()
    tween.set_ease(Tween.EASE_OUT)
    tween.set_trans(Tween.TRANS_QUINT)
    tween.tween_interval(secs)
    tween.tween_callback(hide)
    
func update(): 
    
    setRadius(radius)
    setLength(range)
    
func setRadius(r):

    if cylinder:
        cylinder.mesh.top_radius    = r
        cylinder.mesh.bottom_radius = r
    
func setLength(length):
    
    if cylinder:
        cylinder.mesh.height = length
        cylinder.position.z  = -0.5 * length
