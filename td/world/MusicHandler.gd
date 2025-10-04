class_name MusicHandler
extends Node

var world : World

func _ready():
    
    world = get_node("/root/World")
    Post.subscribe(self)
    
func levelStart():
    
    match world.currentLevel.name:
        "Linea":     %SketchReverb.play()
        "Circulus":  %SketchReverb.play()
        "Quadratum": %Sketch.play()
