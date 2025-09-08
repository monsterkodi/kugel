class_name Bouncer extends Building

var sensorBodies:Array[Node3D]
    
func _ready():
    
    applyCards()
    
    super._ready()
    
func applyCards():
    
    #%Emitter.velocity = 5.0  + Info.countPermCards("Turret Power") * 5.0
    #%Emitter.mass     = 1.0  + Info.countPermCards("Turret Power") * 1.0 
    setSensorRadius(4.5 + Info.countPermCards("Bouncer Range") * 1.5)
    %Sensor.linear_damp = 0.6 + Info.countPermCards("Bouncer Power") * 0.1

func setSensorRadius(r:float):

    #Log.log("setSensorRadius", r)
    %Sensor.scale = Vector3(r, 1, r)
    
func _physics_process(_delta:float):
    
    pass
            
func _on_sensor_body_entered(body: Node3D):
    
    if body.health > 0:
        sensorBodies.append(body)

func _on_sensor_body_exited(body: Node3D):
    
    sensorBodies.erase(body)
    
