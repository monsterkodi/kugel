class_name Sniper extends Building

@export var target  : Node3D

var sensorBodies    : Array[Node3D]
var targetPos       : Vector3
var rotSpeed        : float
var interval        : float
var glowTween       : Tween

@onready var ray: RayCast3D = %Ray
@onready var reloadTimer: Timer = %reloadTimer

func _ready():
    
    if not global_position.is_zero_approx():
        look_at(Vector3.ZERO)
        
    if level(): applyCards()
    
    if target:
        %BarrelTarget.look_at(target.global_position)
    else:
        lookUp()
        
    reloadTimer.timeout.connect(onReload)
        
    super._ready()
        
func applyCards():
    
    var speedCards = level().cards.permLvl(Card.SniperSpeed)
    var rangeCards = level().cards.permLvl(Card.SniperRange)
    
    setSensorRadius(4.0 + rangeCards * 1.0)
    
    interval = 4.0  - speedCards * 0.2
    rotSpeed = PI * 0.2 + speedCards * PI * 0.2

func setSensorRadius(r:float):  

    %Sensor.scale = Vector3(r, r/2.0, r)

func _physics_process(delta:float):
    
    if not reloadTimer.is_stopped():          return
    if %SniperRay.visible:                    return
    if glowTween and glowTween.is_running():  return
    
    if target and target is Enemy:
        
        if target.health <= 0:
            _on_sensor_body_exited(target)
            if not target:
                return
                    
        setTargetPos(target.global_position)
        
        var angle = Utils.rotateTowards($BarrelPivot, -$BarrelTarget.basis.z.normalized(), delta*rotSpeed)
        if absf(angle) < 1.0:
            shoot() 
    else:
        Utils.rotateTowards($BarrelPivot, -$BarrelTarget.basis.z.normalized(), delta*rotSpeed)    

func setTargetPos(pos:Vector3):
    
    targetPos = pos
    %BarrelTarget.look_at(targetPos)
        
func _on_sensor_body_entered(body: Node3D):
    
    if body.health > 0:
        sensorBodies.append(body)
        if not target:
            target = sensorBodies.front()

func _on_sensor_body_exited(body: Node3D):
        
    sensorBodies.erase(body)

    if sensorBodies.size():
        target = sensorBodies.front()
    else:
        target = null

func lookUp():
    
    %BarrelTarget.look_at(global_position + Vector3.UP*10 + Vector3.RIGHT*0.001)

func shoot():
    
    Post.gameSound.emit(self, "sniper")
    %SniperGlow.visible = false
    %SniperRay.shoot()
    reloadTimer.start(interval)
    ray.target_position = Vector3.FORWARD * 100
    ray.force_raycast_update()
    var collider = ray.get_collider()
    while collider:
        collider.die()
        sensorBodies.erase(collider)
        ray.force_raycast_update()
        collider = ray.get_collider()
        
    if sensorBodies.size():
        target = sensorBodies.front()
    
    const svec = Vector3(0.5,2,0.5)
    const tvec = Vector3(1,2,1)
    
    var delinc = 0.15
    var delay  = 2*delinc
    for torus in [%TorusMesh1, %TorusMesh2, %TorusMesh3]:
        var tween : Tween = torus.create_tween()
        tween.set_ease(Tween.EASE_OUT)
        tween.set_trans(Tween.TRANS_ELASTIC)
        tween.tween_property(torus, "scale", svec, interval/4).set_delay(delay)
        tween.tween_property(torus, "scale", tvec, 3*interval/4)
        delay -= delinc
        
func onReload():
    
    %SniperGlow.visible = true
    %SniperGlow.scale   = Vector3.ZERO
    glowTween = create_tween()
    glowTween.set_ease(Tween.EASE_IN)
    glowTween.set_trans(Tween.TRANS_CIRC)
    glowTween.tween_property(%SniperGlow, "scale", Vector3.ONE, 0.6)
