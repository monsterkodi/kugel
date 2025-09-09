class_name CardLaserSpeed
extends CardLaser

@export var lookAt:Vector3:
    set(v): 
        lookAt = v
        update()

func _ready():
    
    super._ready()
    update()

func update():
    
    if is_inside_tree():
        %Laser.get_node("BarrelPivot").look_at(lookAt)
