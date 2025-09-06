extends Node

@export var maxAge = 2.0

var age = 0.0

func _process(delta: float):
    
    age += delta
    if age > maxAge:
        owner.queue_free()
