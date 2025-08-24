extends Node3D

@export var target : Node3D
@export_range(1.0, 10.0, 0.1) var radius:float = 2:
    set(v): setSensorRadius(v)

var sensorBodies: Array[Node3D]

func setSensorRadius(r:float):  

    if %Sensor: %Sensor.scale = Vector3(r, 1, r)
    
func _ready():
    
    if target:
        $BarrelTarget.look_at(target.global_position)
    else:
        $BarrelTarget.look_at(global_position + Vector3.UP*10 + Vector3.RIGHT*0.001)

func _process(_delta:float):
    
    if target and target is Enemy:
        if target.health <= 0:
            _on_sensor_body_exited(target)
            return
            
        var state:PhysicsDirectBodyState3D = PhysicsServer3D.body_get_direct_state(target.get_rid())
        var velocity = state.linear_velocity
        velocity.y = 0
        
        var D = target.global_position - global_position
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
                var  targetPos = target.global_position + V_t * t
                %LaserDot.visible = true
                %LaserDot.global_position = targetPos
                $BarrelTarget.look_at(targetPos)
        
    $BarrelPivot.transform.basis = $BarrelPivot.transform.basis.slerp($BarrelTarget.transform.basis, 0.2)
    
func _on_sensor_body_entered(body: Node3D):
    if body.health > 0:
        sensorBodies.append(body)
        if not target:
            %Emitter.startShooting()
            target = sensorBodies.front()

func _on_sensor_body_exited(body: Node3D):
    
    sensorBodies.erase(body)
    
    if body == target:
        if sensorBodies.size():
            target = sensorBodies.front()
        else:
            target = null
            %LaserDot.visible = false
            %Emitter.stopShooting()
            $BarrelTarget.look_at(global_position + Vector3.UP*10 + Vector3.RIGHT*0.001)
