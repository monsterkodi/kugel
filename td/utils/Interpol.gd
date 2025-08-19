extends Node
class_name Interpol

@export_range(0.0, 4.0, 0.1) var secs:float = 1.0

var target := 0.0
var value  := 0.0

func _physics_process(delta: float) -> void:
    
    if secs == 0:
        value = target
    else:
        if value < target:
            value += delta / secs
            value = minf(value, target)
        elif value > target:
            value -= delta / secs
            value = maxf(value, target)
        
func zero(): target = 0.0

func add(val:float):
    
    target += val
    target = clampf(target, -1, 1)
    
func absmax(val:float):
    
    if val < 0 and val < target or val > target: 
        target = val
