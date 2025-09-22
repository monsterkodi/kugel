class_name Bullet extends RigidBody3D

func _ready():
    
    Utils.level(self).get_node("MultiMesh").add("bullet", self)

func _exit_tree():
    
    Utils.level(self).get_node("MultiMesh").del("bullet", self)

func level_reset(): free()

func getColor() -> Color:
    
    var af = (1.0 - %Lifetime.ageFactor())
    return Color(0.44, 0.44, 1.82, af) 
