class_name Builder extends Node3D

signal done

var vehicle     : Node3D
var ghost       : Node3D
var vanishTween : Tween
var appearTween : Tween
var targetPos   = Vector3(5, 0, 0)

const GHOST_MATERIAL = preload("res://materials/BuilderGhostMaterial.tres")

func _input(event: InputEvent):
    
    if visible and ghost:
    
        if Input.is_action_just_pressed("place_building"):
            get_viewport().set_input_as_handled()
            var building = load(ghost.scene_file_path).instantiate()
            Post.buildingPlaced.emit(building.name)
            get_parent_node_3d().add_child(building)
            building.global_position = targetPos
            done.emit()

func _process(delta:float):
    
    if visible and ghost and vehicle:
        
        if ghost.name == "Shield":
            targetPos = Vector3.ZERO
        else:
            var vehiclePos = vehicle.global_position
            if vehiclePos.length() > 0.01:
                var radius = snappedf(vehiclePos.length(), 5)
                radius = clampf(radius, 5, 25)
                var num:float = 32
                match int(radius):
                    5:  num = 8
                    10: num = 16
                    15: num = 24
                var angle = snappedf(rad_to_deg(vehiclePos.signed_angle_to(Vector3.FORWARD, Vector3.UP)), 360/num)
                targetPos = Vector3.FORWARD.rotated(Vector3.UP, -deg_to_rad(angle))*radius
        ghost.global_position = ghost.global_position.lerp(targetPos, 0.1)
        
func loadVehicle(vehicleName:String):
    
    if vehicle:
        vehicle.cancel_free()
    else:    
        vehicle = load("res://vehicles/%s.tscn" % vehicleName).instantiate()
        get_parent_node_3d().add_child(vehicle)
        
func loadGhost(ghostName:String):
    
    if ghost: 
        ghost.queue_free()
        
    ghost = load("res://world/buildings/%s.tscn" % ghostName).instantiate()
    ghost.name = ghostName
    ghost.inert = true
    get_parent_node_3d().add_child(ghost)
    ghost.global_transform = vehicle.global_transform
    var meshes = ghost.find_children("*Mesh*")
    for mesh in meshes:
        if mesh is MeshInstance3D:
            mesh.set_surface_override_material(0, GHOST_MATERIAL)
    
func appear(trans:Transform3D):
    
    visible = true
    if not vehicle:
        loadVehicle("Drone")
        vehicle.global_transform = trans
        vehicle.body.position.y = 32
    else:
        vanishTween.stop()
    appearTween = vehicle.create_tween()
    appearTween.set_ease(Tween.EASE_OUT)
    appearTween.set_trans(Tween.TRANS_QUINT)
    appearTween.tween_property(vehicle.body, "position:y", 3, 1.0)

func vanish():
    freeGhost()
    appearTween.stop()
    if vehicle:
        vanishTween = get_tree().create_tween()
        vanishTween.set_ease(Tween.EASE_IN)
        vanishTween.set_trans(Tween.TRANS_QUINT)
        vanishTween.tween_property(vehicle.body, "position:y", 32, 0.5)
        vanishTween.finished.connect(freeVehicle)
    
func freeGhost():
    if ghost:
        ghost.queue_free()
        ghost = null
        
func freeVehicle():
    if vehicle:
        vehicle.queue_free()
        vehicle = null
    
        
