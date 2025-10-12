class_name Player
extends Node3D

var vehicleName = "Pill"
var vehicle     : Node3D

func _ready():
    
    #Log.log("ready player one", get_parent_node_3d())
    Post.subscribe(self)
    
func startLevel():
    
    if not vehicle:
        loadVehicle("Pill")
    
func loadVehicle(vehicle_name:String):
    
    var oldTrans : Transform3D
    var corpses = []
    if vehicle: 
        oldTrans = vehicle.global_transform
        corpses = vehicle.collector.corpses
        vehicle.queue_free()
    else:
        oldTrans = Transform3D.IDENTITY.translated(Vector3.BACK)
    vehicleName = vehicle_name
    var res = "res://vehicles/{0}.tscn".format([vehicleName])
    vehicle = load(res).instantiate()

    var f = func(): vehicle.collector.corpses.append_array(corpses) 
    vehicle.ready.connect(f)
    get_parent_node_3d().add_child(vehicle)
    vehicle.player = self
    vehicle.global_transform = oldTrans
    
func save() -> Dictionary:
    
    var dict = {}
    
    dict.transform         = global_transform
    dict.vehicle           = vehicleName
    dict.vehicle_transform = vehicle.transform
    dict.vehicle_velocity  = vehicle.linear_velocity
    
    return dict
    
func load(dict:Dictionary):
    
    loadVehicle(dict.vehicle)
    global_transform         = dict.transform
    vehicle.transform        = dict.vehicle_transform
    vehicle.linear_velocity  = dict.vehicle_velocity
        
func currentLevel(): return get_node("/root/World").currentLevel
            
func _unhandled_input(_event: InputEvent):
    
    if Input.is_action_just_pressed("flying", true):
        get_viewport().set_input_as_handled()
        position.y = 0
        match vehicleName:
            "Pill": loadVehicle("Heli")
            "Heli": loadVehicle("Pill")
