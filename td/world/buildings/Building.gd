class_name Building extends Node3D

var inert = false

func _ready():
    
    add_to_group("level_reset")

func level_reset():
    
    if inert: return
    
    var tween = get_tree().create_tween()
    tween.set_ease(Tween.EASE_IN)
    tween.tween_property(self, "position:y", -5, 0.5)
    tween.finished.connect(queue_free)
