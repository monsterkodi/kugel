class_name DotRing extends Node3D
    
@export_range(0.01, 50.0) var radius = 1.0: 
    set(v) : radius = v; update()

@export_range(4, 1000, 1) var numDots = 8: 
    set(v): numDots = v; update()

@export_range(0.01, 10.0) var dotRadius = 0.1: 
    set(v) : dotRadius = v; update()
    
@export var dotColor = Color(1,1,1):
    set(v) : dotColor = v; update()

@export var dotRes:PackedScene = preload("res://world/Dot.tscn")

var slots:Array[Slot]

func _ready():

    if visible and get_child_count() == 0:
        setup()
    
func update():
    
    Utils.freeChildren(self)
    setup()
    
func setup():

    if is_inside_tree():
        
        for index in range(numDots):
            var dot:Dot = dotRes.instantiate()
            dot.color  = dotColor
            dot.radius = dotRadius
            add_child(dot)
            dot.position = Vector3(0,0,-radius).rotated(Vector3.UP, -deg_to_rad(index * 360.0 / numDots))

func setColor(index, color): 
    
    if index < get_child_count():
        get_child(index).color = color
        
func _on_visibility_changed():
    
    if visible and get_child_count() == 0:
        setup()
