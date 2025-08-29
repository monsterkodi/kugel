class_name Laser extends Building

@export var target : Node3D

@export_range(1, 10, 0.1) var radius:float = 4:
    set(v): radius = v; setSensorRadius(v)

@export_range(0.01, 1, 0.01) var rot_slerp:float = 0.03
    
var sensorBodies: Array[Node3D]
var targetPos:Vector3

func setSensorRadius(r:float):  

    if %Sensor:
        %Sensor.scale = Vector3(r, 1, r)
        %LaserPointer.laserRange = r 
    
func _ready():
    
    setSensorRadius(radius)
    
    if target:
        $BarrelTarget.look_at(target.global_position)
    else:
        lookUp()
        
func _process(_delta:float):
    
    if target and target is Enemy:
        if target.health <= 0:
            _on_sensor_body_exited(target)
            return
        setTargetPos(target.global_position)
        
    $BarrelPivot.transform.basis = $BarrelPivot.transform.basis.slerp($BarrelTarget.transform.basis, rot_slerp)
                
func setTargetPos(pos:Vector3):
    
    targetPos = pos
    $BarrelTarget.look_at(targetPos)
    
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
    
    setTargetPos(global_position + Vector3.UP*2 + Vector3.RIGHT*0.001)
