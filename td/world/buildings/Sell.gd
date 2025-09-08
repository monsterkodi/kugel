class_name Sell extends Building

func _ready():
    
    lookAtCenter()
    
    super._ready()

func _process(delta: float):
    
    lookAtCenter()

func lookAtCenter():
    
    if not global_position.is_zero_approx():
        look_at_from_position(global_position, Vector3.ZERO, Vector3.UP)
