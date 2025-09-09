class_name CardTurretPower
extends CardTurret

@export var lookAt:Vector3:
    set(v): 
        lookAt = v
        if is_inside_tree():
            %Turret.get_node("BarrelPivot").look_at(v)

func _ready():
    
    super._ready()
    lookAt = lookAt
