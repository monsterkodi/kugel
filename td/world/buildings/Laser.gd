class_name Laser extends Building

@export var target:Node3D

var rotSpeed : float
    
var sensorBodies : Array[Node3D]
var targetPos : Vector3
    
func _ready():
        
    if target:
        $Target.look_at(target.global_position)
    else:
        lookUp()
        
    applyCards()
    
    %LaserPointer.rc.add_exception(%Base)

    super._ready()
    
func applyCards():
    
    setSensorRadius(5.0 + Info.countPermCards(Card.LaserRange) * 1.5)
    rotSpeed = PI * 0.25 + Info.countPermCards(Card.LaserSpeed) * PI * 0.25
    %LaserPointer.laserDamage = 2.0 + Info.countPermCards(Card.LaserPower) * 2.0

func setSensorRadius(r:float):  

    if is_inside_tree():
        %Sensor.scale = Vector3(r, r/2.0, r)
        %LaserPointer.laserRange = r
    
func level_reset():
    
    %LaserPointer.visible = false
    super.level_reset()
        
func _physics_process(delta:float):
    
    if target and target is Enemy:
        
        if target.health <= 0:
            _on_sensor_body_exited(target)
            return
            
        setTargetPos(target.global_position)
        #calcTargetPos()
    
    Utils.rotateTowards($BarrelPivot, -$Target.basis.z.normalized(), delta*rotSpeed)    
    #$BarrelPivot.transform.basis = $BarrelPivot.transform.basis.slerp($Target.transform.basis, rot_slerp)

#func calcTargetPos():
    #
    #var state = PhysicsServer3D.body_get_direct_state(target.get_rid())
    #var velocity = state.linear_velocity
    #velocity.y = 0
    #setTargetPos(target.global_position + velocity * 0.01 / rot_slerp)
                
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
