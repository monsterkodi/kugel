class_name Slot extends Node3D

func _ready():
    
    Utils.level(self).get_node("MultiMesh").add("slot", self)
    
func _exit_tree():
    
    var level = Utils.level(self)
    if level:
        level.get_node("MultiMesh").del("slot", self)
    
