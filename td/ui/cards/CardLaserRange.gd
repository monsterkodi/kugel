class_name CardLaserRange
extends CardLaser

func _ready():
    
    super._ready()
    
    %Laser.get_node("BarrelPivot").look_at(Vector3(6, 0, -6))
    %Laser.setSensorRadius(3.0)
