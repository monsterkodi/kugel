class_name Base extends Node3D

var hitPoints:int

func _ready():
    
    Post.subscribe(self)
    setHitPoints(3)
    
func _process(delta:float):
    
    %DotRing.rotate(Vector3.UP, -delta*0.2)

func onHit(): 
    
    setHitPoints(hitPoints - 1)
    Post.baseDamaged.emit(self)
        
func statChanged(statName, value):

    match statName:
        "shieldHitPoints":
            updateDots()        
        
func ringParam(param:String, value:Variant):
    
    var mat:ShaderMaterial = %GroundCircles.get_surface_override_material(0)
    mat.set_shader_parameter(param, value)

func setHitPoints(hp):
    
    hitPoints = clampi(hp, 0, 3)
    Post.statChanged.emit("baseHitPoints", hitPoints)
    if hitPoints == 0:
        onDeath.call_deferred()
    else:
        ringParam("num_rings", hitPoints)
        updateDots()
        
func updateDots():
    
    var world = get_node("/root/World")
    var dots = hitPoints
    if world.has_node("Shield"):
        var shield = world.get_node("Shield")
        dots += shield.hitPoints
    %DotRing.numDots = dots
        
func onDeath():
    
    Post.baseDestroyed.emit()

func _on_center_sphere_body_entered(body: Node):

    if body is Enemy:
        if body.alive():
            onHit()
        else:
            Post.corpseCollected.emit(self)
        body.queue_free()
        
