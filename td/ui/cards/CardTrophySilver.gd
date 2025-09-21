class_name CardTrophySilver
extends Node3D

const silver = preload("uid://b23af3wso6i5m")

func _ready():
    
    for child in Utils.childrenWithClass(self, "MeshInstance3D"):
        child.set_surface_override_material(0, silver)
