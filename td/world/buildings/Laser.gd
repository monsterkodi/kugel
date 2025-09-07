class_name Laser extends Building

@export var target:Node3D

var rot_slerp:float = 0.03
    
var sensorBodies:Array[Node3D]
var targetPos:Vector3
    
func _ready():
        
    if target:
        $Target.look_at(target.global_position)
    else:
        lookUp.call_deferred()
        
    applyCards()
    
    %LaserPointer.rc.add_exception(%Base)

    super._ready()
    
func applyCards():
    
    setSensorRadius(4 * (1.0 + Info.countPermCards("Laser Range") * 0.5))
    rot_slerp = 0.03 * (1.0 + Info.countPermCards("Laser Speed") * 0.5)
    %LaserPointer.laserDamage = 1 + (1.0 + Info.countPermCards("Laser Damage") * 1.0)

func setSensorRadius(r:float):  

    if is_inside_tree():
        Log.log("setSensorRadius", r)
        %Sensor.scale = Vector3(r, 1, r)
        %LaserPointer.laserRange = r
    
func level_reset():
    
    %LaserPointer.visible = false
    super.level_reset()
        
func _physics_process(_delta:float):
    
    if target and target is Enemy:
        if target.health <= 0:
            _on_sensor_body_exited(target)
            return
        calcTargetPos()
        
    $BarrelPivot.transform.basis = $BarrelPivot.transform.basis.slerp($Target.transform.basis, rot_slerp)

func calcTargetPos():
    
    var state = PhysicsServer3D.body_get_direct_state(target.get_rid())
    var velocity = state.linear_velocity
    velocity.y = 0
    setTargetPos(target.global_position + velocity*0.3)
                
func setTargetPos(pos:Vector3):
    
    targetPos = pos
    var dir = Vector3(-0.01,0,0)
    if not global_position.is_zero_approx():
        dir = global_position.normalized()*-0.01
    var up = (Vector3.UP + dir).normalized()
    $Target.look_at(targetPos, up)
    
func _on_sensor_body_entered(body: Node3D):
    if body.health > 0:
        sensorBodies.append(body)
        if not target:
            target = sensorBodies.front()

func _on_sensor_body_exited(body: Node3D):
    
    sensorBodies.erase(body)
    
    if body == target:
        if sensorBodies.size():
            target = sensorBodies.front()
        else:
            target = null
            lookUp()

func lookUp():
    
    setTargetPos(global_position + Vector3.UP*2)
