class_name Slot extends Node3D

func _ready():
    
    Utils.level(self).get_node("MultiMesh").add("slot", self)
    
