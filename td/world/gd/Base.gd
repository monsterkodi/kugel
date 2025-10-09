class_name Base extends Node3D

var hitPoints : int

func _ready():
    
    Post.subscribe(self)
    if not hitPoints:
        setHitPoints(3)
    
func gameResume(): updateDots()
    
func _process(delta:float):
    
    %DotRing.rotate(Vector3.UP, -delta*0.2)
    if %SphereBody.global_position.y < 0.25:
        %SphereBody.global_position.y = 0.25

func onHit(): 
    
    setHitPoints(hitPoints - 1)
    Post.baseDamaged.emit(self)
    Post.gameSound.emit(self, "baseHit", hitPoints)
        
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
    var level = Utils.firstParentWithClass(self, "Level")
    var shield = level.firstPlacedBuildingOfType("Shield")
    if shield:
        dots += shield.hitPoints
    #Log.log("dots", level.name, dots, get_path())
    %DotRing.numDots = dots
        
func onDeath():

    Post.gameSound.emit(self, "baseDied")
    Post.baseDestroyed.emit()

func _on_center_sphere_body_entered(body: Node):

    if body is Enemy:
        if body.alive():
            body.die()
            onHit()
