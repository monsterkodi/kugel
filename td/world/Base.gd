class_name Base extends Node3D

var hitPoints:int

func _ready():
    
    setHitPoints(3)

func onHit(): 
    setHitPoints(hitPoints - 1)
    Post.baseDamaged.emit(self)
        
func ringParam(param:String, value:Variant):
    var mat:ShaderMaterial = %GroundCircles.get_surface_override_material(0)
    mat.set_shader_parameter(param, value)

func setHitPoints(hp):
    
    hitPoints = clampi(hp, 0, 3)
    Post.statChanged.emit("baseHitPoints", hitPoints)
    if hitPoints == 0:
        onDeath()
    else:
        ringParam("num_rings", hitPoints)
        
func onDeath():
    
    Post.baseDestroyed.emit()
    get_tree().call_group("level_reset", "level_reset")
    _ready()

func _on_center_sphere_body_entered(body: Node):

    if body.is_in_group("enemy"):
        if body.alive():
            onHit()
        else:
            Post.corpseCollected.emit()
        body.queue_free()
        
