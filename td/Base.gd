class_name Base extends Node3D

@export var maxBaseHitPoints   = 10
@export var maxShieldHitPoints = 10

var baseHitPoints:int
var shieldHitPoints:int

func onHit(): 
    
    if shieldHitPoints:
        setShieldHitPoints(shieldHitPoints - 1)
    else:
        setBaseHitPoints(baseHitPoints - 1)
        
func ringParam(param:String, value:Variant):
    var mat:ShaderMaterial = %GroundCircles.get_surface_override_material(0)
    mat.set_shader_parameter(param, value)

func setShieldHitPoints(hp):
    
    shieldHitPoints = clampi(hp, 0, maxShieldHitPoints)
    if shieldHitPoints == 0:
        onShieldDown()
    else:
        ringParam("num_rings", shieldHitPoints)
    
func setBaseHitPoints(hp):
    
    baseHitPoints = clampi(hp, 0, maxBaseHitPoints)
    if baseHitPoints == 0:
        onDeath()
    else:
        ringParam("num_rings", baseHitPoints)
        
func onShieldDown():
    
    $ShieldHalo.visible = false       
    ringParam("num_rings", baseHitPoints)

func onDeath():
    
    get_tree().call_group("level_reset", "level_reset")
    _ready()

func _ready() -> void:
    
    $ShieldHalo.visible = true
    setBaseHitPoints(maxBaseHitPoints)
    setShieldHitPoints(maxShieldHitPoints)

func _on_center_sphere_body_entered(body: Node) -> void:
    #Log.log("collision with", body, body.get_groups())
    if body.is_in_group("enemy"):
        body.get_parent().remove_child(body)
        onHit()
        
