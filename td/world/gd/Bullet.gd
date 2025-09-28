class_name Bullet extends RigidBody3D

func _ready():
    
    Utils.level(self).get_node("MultiMesh").add("bullet", self)

func _exit_tree():
    
    Utils.level(self).get_node("MultiMesh").del("bullet", self)

func level_reset(): free()

func _physics_process(delta: float):
    
    var af = 1.0-smoothstep(0.9, 1.0, %Lifetime.ageFactor())
    scale = Vector3(af, af, af)

func getColor() -> Color:
    
    var af = (1.0 - %Lifetime.ageFactor())
    return Color(0.44, 0.44, 1.82, af) 
