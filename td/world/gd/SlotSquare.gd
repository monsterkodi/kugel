class_name SlotSquare extends Node3D

@export_range(1, 64, 1) var numSlotsPerSide : int = 3:
    set(v) : numSlotsPerSide = v; update()
    
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
    
    var sh : int = (numSlotsPerSide-1)/2
    #@warning_ignore("integer_division")
    for index in range(-sh, sh+1):
        for side in range(4):
            var slot:Slot = slotRes.instantiate()
            add_child(slot)
            var p = Vector3(radius, 0, index * (radius-5) / sh)
            p = p.rotated(Vector3.UP, side * deg_to_rad(90))
            slot.global_position = p
        
func _on_visibility_changed():
    
    if visible:
        update()
