class_name Dot
extends Node3D

@export var radius = 1.0
@export var color  = Color(1,1,1) 

func _enter_tree():
    
    add_to_group("dot")
    
func getColor():  return color
func getRadius(): return radius
