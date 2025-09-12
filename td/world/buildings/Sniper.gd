class_name Sniper extends Building

@export var target  : Node3D

var sensorBodies    : Array[Node3D]
var targetPos       : Vector3
var rot_slerp       : float = 0.02
var interval        : float
var shotTween       : Tween
var speedCards      : int
var rangeCards      : int

@onready var ray: RayCast3D = %Ray
@onready var reloadTimer: Timer = %reloadTimer

func _ready():
    
    if not global_position.is_zero_approx():
        look_at(Vector3.ZERO)
        
    applyCards()
    
    if target:
        $BarrelTarget.look_at(target.global_position)
    else:
        lookUp()
        
    super._ready()
    
func applyCards():
    
    speedCards = Info.countPermCards(Card.SniperSpeed)
    rangeCards = Info.countPermCards(Card.SniperRange)
    
    setSensorRadius(8.0 + rangeCards * 2.0)
    
    interval  = 2.5  - speedCards * 0.3
    rot_slerp = 0.03 + speedCards * 0.01

func setSensorRadius(r:float):  

    %Sensor.scale = Vector3(r, 1, r)

func _physics_process(_delta:float):
    
    if target and target is Enemy:
        
        if target.health <= 0:
            _on_sensor_body_exited(target)
            if not target:
                return
                    
        calcTargetPos()
        $BarrelPivot.transform.basis = $BarrelPivot.transform.basis.slerp($BarrelTarget.transform.basis, rot_slerp)
        calcTargetAngle()
    else:
        $BarrelPivot.transform.basis = $BarrelPivot.transform.basis.slerp($BarrelTarget.transform.basis, rot_slerp)
    
func calcTargetAngle():
    
    if reloadTimer.is_stopped():
    
        var angle = $BarrelPivot.global_basis.z.angle_to($BarrelTarget.global_basis.z)
        if rad_to_deg(angle) < 2:
            shoot()
    
func calcTargetPos():
    
    setTargetPos(target.global_position)
                
func setTargetPos(pos:Vector3):
    
    targetPos = pos
    $BarrelTarget.look_at(targetPos)
    
func _on_sensor_body_entered(body: Node3D):
    
    if body.health > 0:
        sensorBodies.append(body)
        Log.log("targets++", sensorBodies)
        if not target:
            target = sensorBodies.front()
    else:
        Log.log("targets??", body)

func _on_sensor_body_exited(body: Node3D):
    
    if not is_inside_tree() or is_queued_for_deletion(): 
        Log.log("???")
        return
    
    sensorBodies.erase(body)
    Log.log("targets--", sensorBodies)
    if sensorBodies.size():
        Log.log("next target")
        target = sensorBodies.front()
    else:
        Log.log("no target")
        target = null

func lookUp():
    
    $BarrelTarget.look_at(global_position + Vector3.UP*10 + Vector3.RIGHT*0.001)

func shoot():
    
    %SniperRay.shoot()
    reloadTimer.start(interval)
    
    ray.target_position = targetPos
    ray.force_raycast_update()
    var collider = ray.get_collider()
    if collider:
        collider.die()
        _on_sensor_body_exited(collider)
        shoot()
