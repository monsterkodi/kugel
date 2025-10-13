class_name SplashClock
extends Clock

func _ready():
    
    %ClockRing.get_surface_override_material(0).set_shader_parameter("Revolution", 0.999)
