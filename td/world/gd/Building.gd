class_name Building extends Node3D

@export var inert = false
var type : String

func _ready():
    
    type = get_script().get_global_name()
    #Log.log("enter_tree", name, inert, type, get_script().get_base_script())
    
    if not inert:
        add_to_group("building")
        Post.subscribe(self)

func level_reset():
    
    var tween = get_tree().create_tween()
    tween.set_ease(Tween.EASE_IN)
    tween.tween_property(self, "position:y", -5, 1.5)
    tween.tween_callback(queue_free)
    
func saveBuilding(array:Array):
    
    var dict = {}
    
    dict.type     = scene_file_path
    dict.position = global_position
    array.append(dict)
