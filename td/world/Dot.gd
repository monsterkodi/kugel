class_name Dot
extends Node3D

@export var radius = 1.0
@export var color  = Color(1,1,1) 

func _ready():
    
    Utils.level(self).get_node("MultiMesh").add("dot", self)
    
func _exit_tree():
    
    Utils.level(self).get_node("MultiMesh").del("dot", self)
    
func getColor():  return color
func getRadius(): return radius
