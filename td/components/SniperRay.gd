class_name SniperRay extends Node3D

@export var radius = 0.5:
    set(v): radius = v; update()
@export var range  = 100.0:
    set(v): range = v; update()

@export var material:ShaderMaterial
@export var glowCurve:Curve

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
    
    var tween = create_tween()

    tween.set_ease(Tween.EASE_OUT)
    tween.set_trans(Tween.TRANS_LINEAR)
    tween.tween_method(onRayTween, 0.0, 1.0, 0.5)
    tween.tween_callback(hide)
    
func onRayTween(value):
    
    var av = 1-value
    var albedo : Color = Color(av, av, av, av)
    var ev = maxf(av, glowCurve.sample(value)*3.0)
    var emission : Color = Color(av, av, ev, av)
    material.set_shader_parameter("albedo", albedo)
    material.set_shader_parameter("emission", emission)
    
    setRadius(radius*(0.2+0.8*av))
    
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
