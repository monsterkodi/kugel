class_name CardTrophyBronce
extends Node3D

const bronce = preload("uid://bou8q8b1rk15t")

func _ready():
    
    for child in Utils.childrenWithClass(self, "MeshInstance3D"):
        child.set_surface_override_material(0, bronce)
