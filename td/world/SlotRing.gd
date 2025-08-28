class_name SlotRing extends Node3D

@export_range(4, 64, 1) var numSlots  = 8.0
@export_range(5, 25, 5) var radius = 5.0

const SLOT = preload("res://world/Slot.tscn")
var slots:Array[Slot]

func _ready():
    
    for index in range(numSlots):
        var slot:Slot = SLOT.instantiate()
        slots.append(slot)
    setup.call_deferred()
    
func setup():
    
    for index in range(numSlots):
        var slot = slots[index]
        get_parent_node_3d().add_child(slot)
        slot.global_position = Vector3(0,0,-radius).rotated(Vector3.UP, deg_to_rad(index * 360.0 / numSlots))
        
        
