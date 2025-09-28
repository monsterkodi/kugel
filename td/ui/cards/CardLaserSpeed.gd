class_name CardLaserSpeed
extends CardLaser

@export var lookAt:Vector3:
    set(v): 
        lookAt = v
        update()

@export var lookAt2:Vector3:
    set(v): 
        lookAt2 = v
        update()

func _ready():
    
    super._ready()
    
    %Laser2.set_process(false)
    %Laser2.set_physics_process(false)

    update()

func update():
    
    if is_inside_tree():
        %Laser.get_node("BarrelPivot").look_at(lookAt)
        %Laser2.get_node("BarrelPivot").look_at(lookAt2)
