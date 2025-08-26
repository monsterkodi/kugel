class_name Builder extends Node3D

var vehicle : Node3D
var ghost   : Node3D

signal done

const GHOST_MATERIAL = preload("uid://f1ntunbkapvi")

func _input(event: InputEvent):
    
    if not visible: return
    if Input.is_action_just_pressed("place_building"):
        get_viewport().set_input_as_handled()
        var building = load(ghost.scene_file_path).instantiate()
        get_parent_node_3d().add_child(building)
        building.global_transform = ghost.global_transform
        done.emit()

func _process(delta:float):
    
    if visible and ghost:
        ghost.global_position = ghost.global_position.lerp(vehicle.global_position, 0.1)
        
func loadVehicle(vehicleName:String):
    
    if vehicle: vehicle.queue_free()
    vehicle = load("res://vehicles/{0}.tscn".format([vehicleName])).instantiate()
    get_parent_node_3d().add_child(vehicle)
    
func loadGhost(ghostName:String):
    
    if ghost: ghost.queue_free()
    ghost = load("res://world/{0}.tscn".format([ghostName])).instantiate()
    get_parent_node_3d().add_child(ghost)
    var meshes = ghost.find_children("*Mesh*")
    for mesh in meshes:
        if mesh is MeshInstance3D:
            mesh.set_surface_override_material(0, GHOST_MATERIAL)
    
func _on_visibility_changed():
    
    if not visible: 
        if ghost:
            ghost.queue_free()
            ghost = null
        if vehicle:
            vehicle.queue_free()
            vehicle = null
    elif visible:
        loadVehicle("Drone")
