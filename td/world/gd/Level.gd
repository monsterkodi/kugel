class_name Level extends Node3D

func _ready():
    
    add_to_group("game")
    #add_to_group("save")
    
    Post.levelStart.connect(levelStart)
    
func levelStart():
    
    var rings = Info.numberOfCardsOwned("Slot Ring")
    Log.log("rings", rings)
    %SlotRing3.visible = (rings >= 1)
    %SlotRing4.visible = (rings >= 2)
    %SlotRing5.visible = (rings >= 3)

func gamePaused():
    
    set_physics_process(false)
    set_process(false)
    
func gameResumed():
    
    set_physics_process(true)
    set_process(true)

func on_save(data:Dictionary):
    
    data.Level = {}
    data.Level.buildings = []
    
    get_tree().call_group("building", "saveBuilding", data.Level.buildings)
    
    #Log.log("on_save", data.Level)

func on_load(data:Dictionary):
    
    if not data.has("Level"): return
    
    get_tree().call_group("level", "level_load")
    
    for building in data.Level.buildings:
        var bld = load(building.type).instantiate()
        var slot = Info.slotForPos(building.position)
        if slot:
            slot.add_child(bld)
        else:
            add_child(bld)
            bld.global_position = building.position
        bld.look_at(Vector3.ZERO)
        
    
    
