class_name CardLaserPower
extends CardLaser

@export var lookAt:Vector3:
    set(v): 
        lookAt = v
        if is_inside_tree():
            %Laser.get_node("BarrelPivot").look_at(v)

func _ready():
    
    super._ready()
    lookAt = lookAt
    #%Laser.get_node("BarrelPivot").look_at(Vector3(3, 0, 0))
