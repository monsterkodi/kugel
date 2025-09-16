class_name Builder extends Node3D

var vanishTween : Tween
var appearTween : Tween
var vehicle     : Node3D
var ghost       : Node3D
var targetSlot  : Node3D
var targetPos   = Vector3(5, 0, 0)

const GHOST_MATERIAL = preload("res://materials/BuilderGhostMaterial.tres")

func _ready():
    
    Post.subscribe(self)

func _input(event: InputEvent):
    
    if visible and ghost:
    
        if event.is_action_pressed("place_building"):
            get_viewport().set_input_as_handled()
            Log.log("place_building")
            placeBuilding()
            
func placeBuilding():
    
    if not targetSlot:
        Log.log("no target slot!")
        return
    assert(targetSlot)
    
    var building = load(ghost.scene_file_path).instantiate()
    Log.log("placeBuilding", building.name)
    Post.buildingBought.emit(building.name)
    building.inert = false
    if targetSlot != get_parent_node_3d():
        if targetSlot.get_child_count():
            var old = targetSlot.get_child(0)
            if old:
                var type = old.type
                Wallet.addPrice(Info.priceForBuilding(type))
                old.free()
                if building.name == "Sell": #and type == "Sell":
                    building.free()
                    Post.buildingSold.emit()
                    return
    targetSlot.add_child(building)
    building.global_position = targetPos
    #building.look_at(Vector3.ZERO)
    Post.buildingPlaced.emit(building)

func _process(delta:float):
    
    if visible and ghost and vehicle:
        if ghost is Shield:
            targetPos  = Vector3.ZERO
            targetSlot = get_parent_node_3d()
        else:
            findTargetPos()
        ghost.global_position = ghost.global_position.lerp(targetPos, 0.1)
        
func findTargetPos():
    
    var slot = Info.slotForPos(vehicle.global_position)    
    if slot:
        
        if targetSlot != slot:
            targetPos  = slot.global_position
            targetSlot = slot
            Post.buildingSlotChanged.emit(targetSlot)
            if slot.get_child_count() == 0:
                if Input.is_action_pressed("place_building") and not Input.is_action_just_pressed("place_building"):
                    placeBuilding()
        
func loadVehicle(vehicleName:String):
    
    if vehicle:
        vehicle.cancel_free()
    else:    
        vehicle = load("res://vehicles/%s.tscn" % vehicleName).instantiate()
        get_parent_node_3d().add_child(vehicle)
        
func buildingGhost(ghostName:String):
    
    if ghost: 
        ghost.free()
        ghost = null
        
    if ghostName.is_empty(): return
        
    ghost = load("res://world/buildings/%s.tscn" % ghostName).instantiate()
    ghost.name = ghostName

    get_parent_node_3d().add_child(ghost)
    ghost.global_position = targetPos
    if not ghost.global_position.is_zero_approx():
        ghost.look_at(Vector3.ZERO)
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
    elif vanishTween:
        vanishTween.stop()
    appearTween = vehicle.create_tween()
    appearTween.set_ease(Tween.EASE_OUT)
    appearTween.set_trans(Tween.TRANS_QUINT)
    appearTween.tween_property(vehicle.body, "position:y", 3, MenuHandler.APPEAR_TIME)

func vanish():
    
    freeGhost()
    if appearTween: appearTween.stop()
    if vehicle:
        vanishTween = vehicle.create_tween()
        vanishTween.set_ease(Tween.EASE_IN)
        vanishTween.set_trans(Tween.TRANS_QUINT)
        vanishTween.tween_property(vehicle.body, "position:y", 32, MenuHandler.VANISH_TIME)
        vanishTween.finished.connect(freeVehicle)
    
func freeGhost():
    
    if ghost:
        ghost.queue_free()
        ghost = null
        
func freeVehicle():
    
    if vehicle:
        vehicle.queue_free()
        vehicle = null
    
        
