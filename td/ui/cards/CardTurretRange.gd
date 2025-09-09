class_name CardTurretRange
extends CardTurret

func _ready():
    
    super._ready()
    
    %Turret.get_node("BarrelPivot").look_at(Vector3(6, 0, -6))
