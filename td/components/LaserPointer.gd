class_name LaserPointer extends Node3D

@export_range(0, 0.1) var radiusTip   = 0.0
@export_range(0, 0.1) var radiusBase  = 0.02 :
    set(v): radiusBase = v; setRadiusBase(v)
@export_range(1, 10)  var laserDamage = 1.0
@export_range(1, 100) var laserRange  = 1.0:
    set(v): laserRange = v; setLength(v)
@export_range(0, 1)   var baseOffset = 0.0

@export var passiveMat:Material = preload("uid://djt41s7f4aal6")
@export var activeMat:Material  = preload("uid://4lqcupd84lbp")

@onready var rc:RayCast3D = %RayCast
@onready var base:Node3D  = %Base

var laser:MeshInstance3D

func _ready():
    
    var cyl = CylinderMesh.new()
    cyl.top_radius    = radiusTip
    cyl.bottom_radius = radiusBase

    laser = MeshInstance3D.new()
    laser.mesh = cyl
    laser.rotation.x = deg_to_rad(-90)
    laser.set_surface_override_material(0, passiveMat)

    setLength(laserRange)
    
    base.position.z = -baseOffset
    base.add_child(laser)
    
func setRadiusBase(r):
    
    if laser and laser.mesh.bottom_radius != r:
        laser.mesh.bottom_radius = r
        
func setLength(length):
    
    if laser and laser.mesh.height != length:
        laser.mesh.height = length
        laser.position.z = -0.5 * length
        rc.target_position.z = -length

func _physics_process(delta:float):
    
    if not is_inside_tree(): return
    
    var collider = rc.get_collider()
    var distance = laserRange
    if collider and collider.is_inside_tree():
        setLength(global_position.distance_to(collider.global_position))
        if collider is Enemy and collider.health > 0 and collider.spawned:
            #if not %laser.playing:
                #%laser.play()
            Post.gameSound.emit(self, "laser")   
            laser.set_surface_override_material(0, activeMat)
            var damage = delta * maxf(0.5, laserDamage * pow(collider.mass, 1.0/2.0))
            #Log.log("damage", damage, collider.health, laserDamage * collider.health)
            if get_parent() is Pill:
                Post.gameSound.emit(self, "laserDamage", minf(damage, delta * collider.mass))
            collider.addDamage(damage)
            return
    else:
        setLength(laserRange)
    %laser.stop()    
    laser.set_surface_override_material(0, passiveMat)

func setDir(dir:Vector3):
    
    if dir.length() > 0.01:
        look_at(global_position + dir)
