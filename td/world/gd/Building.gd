class_name Building extends Node3D

@export var inert = true
var type : String

func _ready():
    
    type = get_script().get_global_name()
    #Log.log("Building.ready inert", inert, "type", type)
    
    if not inert:
        add_to_group("building")
        Post.subscribe(self)

func _to_string() -> String: return type

func level_reset():
    
    var tween = get_tree().create_tween()
    tween.set_ease(Tween.EASE_IN)
    tween.tween_property(self, "position:y", -5, 1.5)
    tween.tween_callback(queue_free)
    
func saveBuilding(array:Array):
    
    var dict = {}
    
    dict.type     = type
    dict.res      = scene_file_path
    dict.position = global_position
    array.append(dict)

func level():
    
    return Utils.firstParentWithClass(self, "Level")
