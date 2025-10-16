class_name Sentinel extends Building

var sensorBodies : Array[Node3D]
var reloadTime   : float  
var chargeTime   : float
var impulsePower : float
var impulseDamage : float
var tween  : Tween

@onready var torus: StaticBody3D = %Torus

const glowColor   = Color(0.609, 0.609, 1.0, 1.0)
const chargeColor = Color(2, 0, 0)
const bounceColor = Color(2, 2, 0)

var powerCards : int
var speedCards : int
var rangeCards : int

var colorVal = 0.0
var colorSrc = 0.0

func _ready():
    
    if level(): applyCards()
    
    super._ready()
    
func applyCards():
    
    powerCards = level().cards.permLvl(Card.SentinelPower)
    speedCards = level().cards.permLvl(Card.SentinelSpeed)
    rangeCards = level().cards.permLvl(Card.SentinelRange)
    
    impulseDamage  = pow(powerCards+1, 2.0) 
    impulsePower   = 4.0 + pow(powerCards+1, 2.0) 
    %Sensor.linear_damp = 0.3 + powerCards * 0.05
    reloadTime     = 1.5  - speedCards * 0.2 
    chargeTime     = 2.0  - speedCards * 0.3
    setSensorRadius(4.5 + rangeCards * 1.0)

func _physics_process(delta: float):
    
    if tween and tween.is_running():
        torus.rotate_y(delta * tween.get_total_elapsed_time())
        return
    
    if sensorBodies.size():
        charge()

func charge():
    
    tween = create_tween()
    colorSrc = 0.0
    tween.tween_method(onChargeTween, 0.0, 1.0, chargeTime)
    tween.tween_callback(bounce)

func decharge():
    
    if torus:
        torus.scale = Vector3.ONE
        colorSrc = minf(colorVal, 1.0)
        tween = create_tween()
        tween.tween_method(onChargeReset, 0.0, 1.0, 0.1)

func bounce():
    
    if sensorBodies.is_empty():
        decharge()
        return
    
    for body in sensorBodies:
        var impulse = body.global_position - %Torus.global_position
        impulse.y = 0.0
        var damage = 0.01 * impulseDamage * pow(body.mass, 0.5)
        #Log.log(damage, body.mass)
        body.addDamage(damage)
        body.apply_central_impulse(impulse.normalized() * impulsePower * pow(body.mass, 0.75))
     
    Post.gameSound.emit(self, "sentinel")   
    
    tween = create_tween()
    tween.set_trans(Tween.TRANS_LINEAR)
    colorSrc = 0.0
    tween.tween_method(onBounceOut,   0.0, 1.0, 0.2)
    tween.tween_method(onBounceReset, 0.0, 1.0, 0.2)

func onChargeTween(value):
    
    colorVal = lerpf(colorSrc, 1.0, value)
    var emission = glowColor.lerp(chargeColor, colorVal)
    %Glow.get_surface_override_material(0).set_shader_parameter("Emission", emission)
    
func onBounceOut(value):
    
    colorVal = lerpf(colorSrc, 1.0, value)
    var s = 1.0 + colorVal*(powerCards+1)/6.0
    torus.scale = Vector3(s,1,s)
    
    var emission = chargeColor.lerp(bounceColor, colorVal)
    %Glow.get_surface_override_material(0).set_shader_parameter("Emission", emission)

func onBounceReset(value):
    
    colorSrc = 1.0
    colorVal = lerpf(colorSrc, 0.0, value)
    var s = 1.0 + colorVal*(powerCards+1)/6.0
    torus.scale = Vector3(s,1,s)
    
    var emission = glowColor.lerp(bounceColor, colorVal)
    %Glow.get_surface_override_material(0).set_shader_parameter("Emission", emission)

func onChargeReset(value):
    
    colorVal = lerpf(colorSrc, 0.0, value)
    var emission = glowColor.lerp(chargeColor, colorVal)
    %Glow.get_surface_override_material(0).set_shader_parameter("Emission", emission)

func setSensorRadius(r:float):

    %Sensor.scale = Vector3(r, r/2.0, r)
    
func _on_sensor_body_entered(body: Node3D):
    
    if body.health > 0:
        sensorBodies.append(body)

func _on_sensor_body_exited(body: Node3D):
    
    sensorBodies.erase(body)
    
    if sensorBodies.is_empty():
        if tween and tween.is_running(): 
            tween.stop()
            decharge()
    
