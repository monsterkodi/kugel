class_name CardTurretSpeed
extends CardTurret

func _ready():
    
    super._ready()
    
    Utils.setParent(%Bullets, %Turret.get_node("BarrelPivot"))
