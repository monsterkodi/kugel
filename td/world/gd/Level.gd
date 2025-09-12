class_name Level extends Node3D

func _ready():
    
    name = "Level"
    add_to_group("game")
    #add_to_group("save")
    
    Post.subscribe(self)
    
func applyCards():
    
    var rings = Info.countPermCards(Card.SlotRing)
    #Log.log("rings", rings)
    %SlotRing1.visible = true
    %SlotRing2.visible = (rings >= 1)
    %SlotRing3.visible = (rings >= 2)
    %SlotRing4.visible = (rings >= 3)
    %SlotRing5.visible = (rings >= 4)
    %SlotRing6.visible = (rings >= 5)

func gamePaused():
    
    set_physics_process(false)
    set_process(false)
    
func gameResumed():
    
    set_physics_process(true)
    set_process(true)

func on_save(data:Dictionary):
    
    data.Level = {}
    data.Level.buildings = []
    
    #get_tree().call_group("building", "saveBuilding", data.Level.buildings)
    
    Log.log("on_save", data.Level)

func on_load(data:Dictionary):
    
    if not data.has("Level"): return
    
    #for building in data.Level.buildings:
        #var bld = load(building.type).instantiate()
        #var slot = Info.slotForPos(building.position)
        #if slot:
            #slot.add_child(bld)
        #else:
            #add_child(bld)
            #bld.global_position = building.position
        #if not bld.global_position.is_zero_approx():
            #bld.look_at(Vector3.ZERO)
        
    
    
