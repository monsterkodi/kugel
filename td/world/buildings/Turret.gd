class_name Turret extends Building

@export var target : Node3D

var sensorBodies:Array[Node3D]
var targetPos:Vector3
var rot_slerp:float = 0.02
var shotTween:Tween
var speedCards:int
var powerCards:int
var rangeCards:int
    
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
    
    speedCards = Info.countPermCards("Turret Speed")
    powerCards = Info.countPermCards("Turret Power")
    rangeCards = Info.countPermCards("Turret Range")
    
    %Emitter.delay    = 0.8  - speedCards * 0.1
    %Emitter.interval = 0.5  - speedCards * 0.07
    %Emitter.velocity = 5.0  + powerCards * 3.0
    %Emitter.mass     = 1.0  + powerCards * 2.0 
    setSensorRadius(4.0 + rangeCards * 1.0)
    rot_slerp = 0.02 + speedCards * 0.01

func setSensorRadius(r:float):  

    %Sensor.scale = Vector3(r, 1, r)

func _physics_process(_delta:float):
    
    if target and target is Enemy:
        if target.health <= 0:
            _on_sensor_body_exited(target)
            return
                    
        calcTargetPos()
        
    $BarrelPivot.transform.basis = $BarrelPivot.transform.basis.slerp($BarrelTarget.transform.basis, rot_slerp)
    
func calcTargetPos():
    
    var state:PhysicsDirectBodyState3D = PhysicsServer3D.body_get_direct_state(target.get_rid())
    var velocity = state.linear_velocity
    velocity.y = 0
    
    var D = target.global_position - %Emitter.global_position
    var V_b = %Emitter.velocity
    var V_t = velocity
    var a = V_b * V_b - V_t.dot(V_t)
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
            
func setTargetPos(pos:Vector3):
    
    targetPos = pos
    $BarrelTarget.look_at(targetPos)
    
func _on_sensor_body_entered(body: Node3D):
    
    if body.health > 0:
        sensorBodies.append(body)
        if not target:
            target = sensorBodies.front()
            %Emitter.start()

func _on_sensor_body_exited(body: Node3D):
    
    sensorBodies.erase(body)
    
    if body == target:
        if sensorBodies.size():
            target = sensorBodies.front()
        else:
            target = null
            if %Emitter:
                %Emitter.stop()
            #lookUp()

func lookUp():
    
    $BarrelTarget.look_at(global_position + Vector3.UP*10 + Vector3.RIGHT*0.001)

func shotFired():
    
    var secs = %Emitter.interval / 3.0
    shotTween = create_tween()
    shotTween.tween_property(%BarrelMesh, "position:z",  0.2 + 0.15 * powerCards, secs)
    shotTween.tween_property(%BarrelMesh, "position:z",  0.0, 2*secs)
