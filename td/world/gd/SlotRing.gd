class_name SlotRing extends Node3D

@export_range(4, 64, 1) var numSlots = 8: 
    set(v) : numSlots = v; update()
    
@export_range(0.01, 100) var radius  = 5.0: 
    set(v) : radius = v; update()

@export var slotRes:PackedScene = preload("res://world/Slot.tscn")

var slots:Array[Slot]

func _ready():

    if visible:
        update()
    
func update():
    
    if not is_inside_tree(): return
    
    Utils.freeChildren(self)
    
    for index in range(numSlots):
        var slot:Slot = slotRes.instantiate()
        add_child(slot)
        slot.global_position = Vector3(0,0,-radius).rotated(Vector3.UP, deg_to_rad(index * 360.0 / numSlots))
        
func _on_visibility_changed():
    
    if visible:
        update()
