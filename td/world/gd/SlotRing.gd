class_name SlotRing extends Node3D

@export_range(4, 64, 1) var numSlots = 8.0
@export_range(5, 25, 5) var radius   = 5.0

const SLOT = preload("res://world/Slot.tscn")
var slots:Array[Slot]

func _ready():

    Log.log("Slot Ring", visible, slots.is_empty())
    if visible and slots.is_empty():
        setup()
    
func setup():

    Log.log("Slot Ring", numSlots, radius)
    for index in range(numSlots):
        var slot:Slot = SLOT.instantiate()
        slots.append(slot)
    
    for index in range(numSlots):
        var slot = slots[index]
        #get_parent_node_3d().add_child(slot)
        add_child(slot)
        slot.global_position = Vector3(0,0,-radius).rotated(Vector3.UP, deg_to_rad(index * 360.0 / numSlots))
        
func _on_visibility_changed():
    
    if visible and slots.is_empty():
        setup()
