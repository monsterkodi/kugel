class_name Builder extends Node3D

signal done

var vehicle     : Node3D
var ghost       : Node3D
var vanishTween : Tween

const GHOST_MATERIAL = preload("uid://f1ntunbkapvi")

func _input(event: InputEvent):
    
    if visible and ghost:
    
        if Input.is_action_just_pressed("place_building"):
            get_viewport().set_input_as_handled()
            var building = load(ghost.scene_file_path).instantiate()
            Post.buildingBuild.emit(building)
            get_parent_node_3d().add_child(building)
            building.global_transform = ghost.global_transform
            done.emit()

func _process(delta:float):
    
    if visible and ghost:
        
        ghost.global_position = ghost.global_position.lerp(vehicle.global_position, 0.1)
        
func loadVehicle(vehicleName:String):
    
    if vehicle:
        vehicle.cancel_free()
    else:    
        vehicle = load("res://vehicles/{0}.tscn".format([vehicleName])).instantiate()
        get_parent_node_3d().add_child(vehicle)
        
func loadGhost(ghostName:String):
    
    if ghost: 
        ghost.queue_free()
        
    ghost = load("res://world/{0}.tscn".format([ghostName])).instantiate()
    get_parent_node_3d().add_child(ghost)
    var meshes = ghost.find_children("*Mesh*")
    for mesh in meshes:
        if mesh is MeshInstance3D:
            mesh.set_surface_override_material(0, GHOST_MATERIAL)
    
func appear(trans:Transform3D):
    
    visible = true
    loadVehicle("Drone")
    vehicle.global_transform = trans

func vanish():
    
    freeGhost()
    vanishTween = get_tree().create_tween()
    vanishTween.set_ease(Tween.EASE_IN)
    vanishTween.tween_property(vehicle, "position:y", 16, 0.5)
    vanishTween.finished.connect(freeVehicle)
    
func freeGhost():
    if ghost:
        ghost.queue_free()
        ghost = null
        
func freeVehicle():
    if vehicle:
        vehicle.queue_free()
        vehicle = null
    
        
