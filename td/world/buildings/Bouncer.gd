class_name Bouncer extends Building

var sensorBodies : Array[Node3D]
var reloadTime   : float  
var chargeTime   : float
var impulsePower : float
var bounceTween  : Tween
var chargeTween  : Tween

const glowColor   = Color(0.6, 0.6, 1.0)
const chargeColor = Color(2, 0, 0)
const bounceColor = Color(2, 2, 0)

func _ready():
    
    applyCards()
    
    super._ready()
    
func applyCards():
    
    var powerCards = Info.countPermCards(Card.BouncerPower)
    var speedCards = Info.countPermCards(Card.BouncerSpeed)
    var rangeCards = Info.countPermCards(Card.BouncerRange)
    
    impulsePower   = (1.0 + powerCards) * 10.0
    %Sensor.linear_damp = 0.2 + powerCards * 0.05
    reloadTime     = 1.5  - speedCards * 0.2 
    chargeTime     = 2.0  - speedCards * 0.3
    setSensorRadius(4.5 + rangeCards * 1.0)

func _physics_process(delta: float):
    
    if chargeTween and chargeTween.is_running(): return
    if bounceTween and bounceTween.is_running(): return
    
    if sensorBodies.size():
        charge()

func charge():
    
    chargeTween = create_tween()
    chargeTween.tween_method(onChargeTween, 0.0, 1.0, chargeTime)
    chargeTween.tween_callback(bounce)

func bounce():
    
    if sensorBodies.is_empty():
        bounceTween = create_tween()
        bounceTween.tween_method(onChargeReset, 1.0, 0.0, 0.2)
        return
    
    for body in sensorBodies:
        var impulse = body.global_position - %Torus.global_position
        impulse.y = 0.0
        body.apply_central_impulse(impulse.normalized() * impulsePower)
        
    bounceTween = create_tween()
    bounceTween.set_trans(Tween.TRANS_LINEAR)
    bounceTween.tween_method(onBounceOut,   0.0, 1.0, 0.2)
    bounceTween.tween_method(onBounceReset, 1.0, 0.0, 0.2)

func onChargeTween(value):
    
    var emission = glowColor.lerp(chargeColor, value)
    %Glow.get_surface_override_material(0).set_shader_parameter("Emission", emission)
    
func onBounceOut(value):
    
    var s = 1.0 + value
    %Torus.scale = Vector3(s,1,s)
    
    var emission = chargeColor.lerp(bounceColor, value)
    %Glow.get_surface_override_material(0).set_shader_parameter("Emission", emission)

func onBounceReset(value):
    
    var s = 1.0 + value
    %Torus.scale = Vector3(s,1,s)
    
    var emission = glowColor.lerp(bounceColor, value)
    %Glow.get_surface_override_material(0).set_shader_parameter("Emission", emission)

func onChargeReset(value):
    
    var emission = glowColor.lerp(chargeColor, value)
    %Glow.get_surface_override_material(0).set_shader_parameter("Emission", emission)

func setSensorRadius(r:float):

    %Sensor.scale = Vector3(r, r/2.0, r)
    
func _on_sensor_body_entered(body: Node3D):
    
    if body.health > 0:
        sensorBodies.append(body)

func _on_sensor_body_exited(body: Node3D):
    
    sensorBodies.erase(body)
    
