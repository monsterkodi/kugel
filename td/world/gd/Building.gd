class_name Building extends Node3D

var inert = false
var type : String

func _ready():
    pass

func _enter_tree():
    
    type = get_script().get_global_name()
    #Log.log("enter_tree", name, inert, type, get_script().get_base_script())
    
    if not inert:
        add_to_group("level")
        add_to_group("building")

func level_reset():
    
    var tween = get_tree().create_tween()
    tween.set_ease(Tween.EASE_IN)
    tween.tween_property(self, "position:y", -5, 1.5)
    tween.tween_callback(queue_free)
    
func level_load():
    
    get_parent_node_3d().remove_child(self)
    queue_free()
    
func saveBuilding(array:Array):
    
    var dict = {}
    
    dict.type     = scene_file_path
    dict.position = global_position
    array.append(dict)
