class_name LaserPointer extends Node3D

@onready var rc:RayCast3D = $RayCast3D
@onready var laser:MeshInstance3D = %LaserMesh
@onready var base:Node3D = %LaserBase
        
var laserMat:StandardMaterial3D 

func _ready():
    
    laserMat = laser.get_surface_override_material(0)

func _physics_process(delta:float):
    var collider = rc.get_collider()
    var distance = 10
    if collider:
        var pos = collider.global_position
        distance = global_position.distance_to(pos)
        if collider is Enemy and collider.health >= 0:
            laserMat.albedo_color = Color(2,0,0,1)
    else:
        laserMat.albedo_color = Color(0,0,0,0.5)
    base.scale = Vector3(1,1,distance)

func setDir(dir:Vector3):
    if dir.length() > 0.01:
        #Log.log("dir", dir.length())
        look_at(global_position + dir)
