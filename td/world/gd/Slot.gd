class_name Slot extends Node3D

func _ready():
    
    if visible and get_parent().visible: _on_visibility_changed()
    
func _exit_tree():
    
    visible = false
    
func _on_visibility_changed():
    
    var level = Utils.level(self)
    if level:
        if visible and get_parent().visible:
            level.get_node("MultiMesh").add("slot", self)
        else:
            level.get_node("MultiMesh").del("slot", self)
