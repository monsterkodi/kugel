class_name CardLaserPower
extends CardLaser

@export var lookAt:Vector3:
    set(v): 
        lookAt = v
        if is_inside_tree():
            %Laser.get_node("BarrelPivot").look_at(v)

func _ready():
    
    super._ready()
    
    %Laser.activate()
    
    lookAt = lookAt
