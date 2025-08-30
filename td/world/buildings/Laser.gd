class_name Laser extends Building

@export var target:Node3D

@export_range(1, 10, 0.1) var radius:float = 4:
    set(v): radius = v; setSensorRadius(v)

@export_range(0.01, 1, 0.01) var rot_slerp:float = 0.03
    
var sensorBodies:Array[Node3D]
var targetPos:Vector3

func setSensorRadius(r:float):  

    if is_inside_tree():
        %Sensor.scale = Vector3(r, 1, r)
        %LaserPointer.laserRange = r 
    
func level_reset():
    
    %LaserPointer.visible = false
    super.level_reset()
    
func _ready():
        
    if target:
        $Target.look_at(target.global_position)
    else:
        lookUp.call_deferred()
        
    setSensorRadius(radius)
    
    %LaserPointer.rc.add_exception(%Base)

    super._ready()
        
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
    setTargetPos(target.global_position + velocity*0.5)
                
func setTargetPos(pos:Vector3):
    
    targetPos = pos
    var up = (Vector3.UP + global_position.normalized()*-0.01).normalized()
    #var tn = (targetPos-global_position).normalized()
    #if tn.dot(up) == 1.0:
        #up = global_position.normalized()
        #Log.log("up", up)
    #Log.log("dot", tn.dot(up))
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
            %LaserDot.visible = false
            lookUp()

func lookUp():
    
    setTargetPos(global_position + Vector3.UP*2)
