extends Node3D

var vehicleName := "Pill"
var vehicle : Node3D

func _ready() -> void:
    
    Log.log("ready player one", get_parent_node_3d(), get_world_3d())

func loadVehicle(vehicle_name:String):
    
    if vehicle: vehicle.queue_free()
    vehicleName = vehicle_name
    var res = "res://vehicles/{0}.tscn".format([vehicleName])
    vehicle = load(res).instantiate()
    if vehicle_name == "Pill":
        get_parent_node_3d().add_child(vehicle)
        vehicle.transform = transform
        vehicle.player = self
    else:
        add_child(vehicle)
    
func _unhandled_input(_event: InputEvent) -> void:
    
    if Input.is_action_just_pressed("alt_right", true):
        get_viewport().set_input_as_handled()
        position.y = 0
        match vehicleName:
            "Pill": loadVehicle("Car")
            "Car":  loadVehicle("Heli")
            "Heli": loadVehicle("Pill")
        
func on_save(data:Dictionary):

    data.Player = {}
    data.Player.transform = transform
    data.Player.vehicle   = vehicleName
    
func on_load(data:Dictionary):
    
    if not data.has("Player"): return
    
    transform = data.Player.transform
    loadVehicle(data.Player.vehicle)

func input_enable():  set_process_unhandled_input(true) 
func input_disable(): set_process_unhandled_input(false)
