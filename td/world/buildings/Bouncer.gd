class_name Bouncer extends Building

var sensorBodies:Array[Node3D]
    
func _ready():
    
    applyCards()
    
    super._ready()
    
func applyCards():
    
    setSensorRadius(4.5 + Info.countPermCards(Card.BouncerRange) * 1.0)
    %Sensor.linear_damp = 0.2 + Info.countPermCards(Card.BouncerPower) * 0.05

func setSensorRadius(r:float):

    %Sensor.scale = Vector3(r, 1, r)
    
func _on_sensor_body_entered(body: Node3D):
    
    if body.health > 0:
        sensorBodies.append(body)

func _on_sensor_body_exited(body: Node3D):
    
    sensorBodies.erase(body)
    
