@tool
extends Node

@export var bullet:Color = Color(0.5, 0.5, 4)
@export var turretSensor:Color = Color(0.5, 0.5, 1, 0.75)
const turretSensorMaterial:ShaderMaterial = preload("uid://b1gsuujsn28vt")

func _ready() -> void:
    #Log.log("HELLO Color", ResourceLoader.has_cached("uid://b1gsuujsn28vt"))
    #var editorInspector = EditorInterface.get_inspector()
    #Log.log("HELLO Inspector", EditorInterface)
    #Log.log("EDITOR?", Engine.is_editor_hint(), Engine.is_embedded_in_editor())
    if Engine.is_editor_hint():
        Log.log("connected", EditorInterface.get_inspector().property_edited.has_connections())
        if not EditorInterface.get_inspector().property_edited.has_connections():
            EditorInterface.get_inspector().property_edited.connect(inspectorPropertyEdited)
    #else:
        #Log.log("game current_scene", get_tree().current_scene, get_tree())

func inspectorPropertyEdited(property):
    
    var obj = EditorInterface.get_inspector().get_edited_object()
    if not obj is Node: return
    #Log.log("propedit", property, obj, obj.get_tree())

    #obj.get_tree().root.print_tree_pretty()
    #obj.get_tree()
    
    #Log.log("current_scene", obj.get_tree().current_scene)
    #Log.log("edited_scene_root", obj.get_tree().edited_scene_root)
    
    match property:
        "turretSensor":
            Log.log("has_cached", ResourceLoader.has_cached("uid://b1gsuujsn28vt"),
                turretSensorMaterial.get_shader_parameter("Color"),
                obj.get(property))
            turretSensorMaterial.set_shader_parameter("Color", Color(1,0,1,0.5))
            Log.log("     after", ResourceLoader.has_cached("uid://b1gsuujsn28vt"),
                turretSensorMaterial.get_shader_parameter("Color"),
                obj.get(property))

func _set(property: StringName, value: Variant) -> bool:
    
    Log.log("Color.set", property, value)
    print("Color.set ", property, value)
    match property:
        "turretSensor":
            turretSensorMaterial.set_shader_parameter("Color", Color(0,0,1,0.5))
    return false
