class_name Turret extends Building

@export var target : Node3D

var sensorBodies : Array[Node3D]
var targetPos    : Vector3
var rotSpeed     : float
var shotTween    : Tween
var world        : World
var powerCards   : int

var interval  = 1.0
var velocity  = 2.0
var mass      = 1.0

@onready var emitter     : Node3D = %Emitter
@onready var reloadTimer : Timer = %reloadTimer
@export  var bulletRes   : Resource

func _ready():
    
    world = get_node("/root/World")
    
    if not global_position.is_zero_approx():
        look_at(Vector3.ZERO)
        
    applyCards()
    
    if target:
        $BarrelTarget.look_at(target.global_position)
    else:
        lookUp()
        
    super._ready()
    
func applyCards():
    
    var speedCards = Info.countPermCards(Card.TurretSpeed)
    var rangeCards = Info.countPermCards(Card.TurretRange)
    powerCards = Info.countPermCards(Card.TurretPower)
    
    interval = 0.5  - speedCards * 0.07
    velocity = 5.0  + powerCards * 5.0
    mass     = 5.0  + powerCards * 10.0 
    setSensorRadius(5.0 + rangeCards * 1.0)
    rotSpeed = PI * 0.2 + speedCards * PI * 0.2

func setSensorRadius(r:float):  

    %Sensor.scale = Vector3(r, 1, r)

func _physics_process(delta:float):
    
    if target and target is Enemy:
        
        if target.health <= 0:
            _on_sensor_body_exited(target)
            return
                    
        calcTargetPos()
        var angle = Utils.rotateTowards($BarrelPivot, -$BarrelTarget.basis.z.normalized(), delta*rotSpeed)
        if absf(angle) < 0.1 and reloadTimer.is_stopped():
            shoot() 
    else:
        Utils.rotateTowards($BarrelPivot, -$BarrelTarget.basis.z.normalized(), delta*rotSpeed)

func shoot():
    
    reloadTimer.start(interval)
    
    var bullet:Node3D = bulletRes.instantiate()
    world.currentLevel.get_node("Bullets").add_child(bullet)
    bullet.mass = mass
    bullet.global_transform = emitter.global_transform
    bullet.linear_velocity  = emitter.global_basis.z * -velocity
    %fire.play()
    
    var secs = interval / 3.0
    shotTween = create_tween()
    shotTween.set_ease(Tween.EASE_OUT)
    shotTween.set_trans(Tween.TRANS_BOUNCE)
    shotTween.tween_property(%BarrelMesh, "position:z",  0.1 + 0.1 * powerCards, secs)
    shotTween.tween_property(%BarrelMesh, "position:z",  0.0, 2*secs)
        
func calcTargetPos():
    
    var state:PhysicsDirectBodyState3D = PhysicsServer3D.body_get_direct_state(target.get_rid())
    var V_t = state.linear_velocity
    V_t.y = 0
    
    var D = target.global_position - emitter.global_position
    var a = velocity * velocity - V_t.dot(V_t)
    var b = -2 * D.dot(V_t)
    var c = -D.dot(D)
    var discriminant = b*b - 4*a*c
    if discriminant >= 0:
        var ds = sqrt(discriminant)
        var t1 = (-b - ds) / (2*a)
        var t2 = (-b + ds) / (2*a)
        var t = null
        if t1 >= 0 and t2 >= 0:
            t = min(t1, t2)
        elif t1 >= 0: t = t1
        elif t2 >= 0: t = t2
        if t != null:
            setTargetPos(target.global_position + V_t * t)
            return
    #Log.log("fallback")
    setTargetPos(target.global_position)
            
func setTargetPos(pos:Vector3):
    
    targetPos = pos
    $BarrelTarget.look_at(targetPos)
    
func _on_sensor_body_entered(body: Node3D):
    
    if body.health > 0:
        sensorBodies.append(body)
        if not target:
            target = sensorBodies.front()

func _on_sensor_body_exited(body: Node3D):
    
    if not is_inside_tree() or is_queued_for_deletion(): 
        Log.log("???")
        return
    
    sensorBodies.erase(body)
    
    if body == target:
        if sensorBodies.size():
            target = sensorBodies.front()
        else:
            target = null

func lookUp():
    
    $BarrelTarget.look_at(global_position + Vector3.UP*10 + Vector3.RIGHT*0.001)

    
