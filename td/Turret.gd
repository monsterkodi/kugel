extends Node3D

@export var target : Node3D
@export_range(1.0, 10.0, 0.1) var radius:float = 2:
    set(v): setSensorRadius(v)

var sensorBodies: Array[Node3D]

func setSensorRadius(r:float):   

    if %Sensor: %Sensor.scale = Vector3(r, 1, r)
    
func _ready() -> void:
    
    $BarrelTarget.look_at(global_position + Vector3.UP*10 + Vector3.RIGHT*0.001)

func _process(_delta: float) -> void:
    
    if target:
        if target.health <= 0:
            _on_sensor_body_exited(target)
            return
        $BarrelTarget.look_at(target.global_position)
        
    $BarrelPivot.transform.basis = $BarrelPivot.transform.basis.slerp($BarrelTarget.transform.basis, 0.2)
    
func _on_sensor_body_entered(body: Node3D) -> void:
    if body.health > 0:
        sensorBodies.append(body)
        if not target:
            %Emitter.startShooting()
            target = sensorBodies.front()

func _on_sensor_body_exited(body: Node3D) -> void:
    
    sensorBodies.erase(body)
    
    if body == target:
        if sensorBodies.size():
            target = sensorBodies.front()
        else:
            target = null
            %Emitter.stopShooting()
            $BarrelTarget.look_at(global_position + Vector3.UP*10 + Vector3.RIGHT*0.001)
