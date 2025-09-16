class_name Sniper extends Building

@export var target  : Node3D

var sensorBodies    : Array[Node3D]
var targetPos       : Vector3
var rotSpeed        : float
var interval        : float
var shotTween       : Tween

@onready var ray: RayCast3D = %Ray
@onready var reloadTimer: Timer = %reloadTimer

func _ready():
    
    if not global_position.is_zero_approx():
        look_at(Vector3.ZERO)
        
    applyCards()
    
    if target:
        %BarrelTarget.look_at(target.global_position)
    else:
        lookUp()
        
    super._ready()
    
func applyCards():
    
    var speedCards = Info.countPermCards(Card.SniperSpeed)
    var rangeCards = Info.countPermCards(Card.SniperRange)
    
    setSensorRadius(5.0 + rangeCards * 1.0)
    
    interval = 2.5  - speedCards * 0.3
    rotSpeed = PI * 0.2 + speedCards * PI * 0.2

func setSensorRadius(r:float):  

    %Sensor.scale = Vector3(r, 1, r)

func _physics_process(delta:float):
    
    if %SniperRay.visible: return
    
    if target and target is Enemy:
        
        if target.health <= 0:
            _on_sensor_body_exited(target)
            if not target:
                return
                    
        setTargetPos(target.global_position)
        
        var angle = Utils.rotateTowards($BarrelPivot, -$BarrelTarget.basis.z.normalized(), delta*rotSpeed)
        if absf(angle) < 0.1 and reloadTimer.is_stopped():
            shoot() 
    else:
        Utils.rotateTowards($BarrelPivot, -$BarrelTarget.basis.z.normalized(), delta*rotSpeed)    

func setTargetPos(pos:Vector3):
    
    targetPos = pos
    %BarrelTarget.look_at(targetPos)
    
    #var dir = Vector3(-0.01,0,0)
    #if not global_position.is_zero_approx():
        #dir = global_position.normalized()*-0.01
    #var up = (Vector3.UP + dir).normalized()
    #$Target.look_at(targetPos, up)
    
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
        #Log.log("shoot next target")
        target = sensorBodies.front()
