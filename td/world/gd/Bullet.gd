class_name Bullet extends RigidBody3D

func level_reset(): queue_free()

func getColor() -> Color:
    
    var af = (1.0 - %Lifetime.ageFactor())
    return Color(0.44, 0.44, 1.82, af) 
