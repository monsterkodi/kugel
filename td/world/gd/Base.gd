class_name Base extends Node3D

var hitPoints : int
var world     : World

func _ready():
    
    world = get_node("/root/World")
    Post.subscribe(self)
    if not hitPoints:
        setHitPoints(3)
    #Log.log("base ready", hitPoints)
    
func _process(delta:float):
    
    %DotRing.rotate(Vector3.UP, -delta*0.2)
    if %SphereBody.global_position.y < 0.25:
        Log.log("asjust center sphere", %SphereBody.global_position.y)
        %SphereBody.global_position.y = 0.25

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
    
    var dots = hitPoints
    if world.has_node("Shield"):
        dots += world.get_node("Shield").hitPoints
    %DotRing.numDots = dots
        
func onDeath():
    Log.log("onDeath")
    Post.baseDestroyed.emit()

func _on_center_sphere_body_entered(body: Node):

    if body is Enemy:
        if body.alive():
            body.die()
            onHit()
