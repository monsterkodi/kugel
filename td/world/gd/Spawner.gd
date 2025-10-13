class_name Spawner
extends Node3D

@export var spawnee:Resource

@export var activation_level:int = 0

@export_range(1.0, 10.0,  1.0) var mass_initial       = 1.0
@export_range(0.0, 100,  0.1)  var velocity_initial   = 2.5

@export var mass_increment     = 0.2
@export var mass_max           = 2000.0
@export var velocity_increment = 0.05
@export var velocity_max       = 1750.0
@export var ident              = 0 
@export var curve : Curve

var activeDotColor  = Color(1,0,0)
var passiveDotColor = Color(0.02,0.02,0.02)
            
var mass        : float
var velocity    : float
var active      = false
var inert       = false

var spawnedBody : RigidBody3D
var level       : Level
var enemies     : Node3D

const spawnerHolePassiveMaterial = preload("uid://djrtyqmjy623u")
const spawnerHoleActiveMaterial  = preload("uid://chltotc0ohct")
                                                
func _ready():

    level = Utils.firstParentWithClass(self, "Level")
    enemies = level.get_node("Enemies")
    assert(enemies)
    velocity = velocity_initial
    mass     = mass_initial
    
    inert = level.inert
    if not inert:
        Post.subscribe(self)
    
    var sf = 0.62
    var sc = Vector3(sf, sf, sf)
    %Body.scale = sc
    %Hole.scale = sc
    %Body.position.y = -sf*1.4
    
    if not level.inert and ident:
        %IdentRing.get_surface_override_material(0).set_shader_parameter("circleCount", float(ident))
    
    if activation_level == 0:
        activate()
    else:
        deactivate()

func save() -> Dictionary:
    
    var dict = {}
    
    dict.active    = active
    dict.velocity  = velocity
    dict.mass      = mass
    
    return dict
    
func load(dict:Dictionary):
    
    if dict.active: activate()
    else:           deactivate()
    
    velocity = dict.velocity
    mass     = dict.mass
        
func activate():
    
    if inert: return
    
    active = true
    %Dot.color = activeDotColor
    %Dot.visible = false
    %Hole.set_surface_override_material(0, spawnerHoleActiveMaterial)
    %IdentRing.get_surface_override_material(0).set_shader_parameter("dotColor", Color(1.5,0,0))

func deactivate():
    
    active = false
    %Dot.visible = true
    %Dot.color = passiveDotColor
    %Hole.set_surface_override_material(0, spawnerHolePassiveMaterial)
    %IdentRing.get_surface_override_material(0).set_shader_parameter("dotColor", Color(0.16,0.16,0.16))

func statChanged(statName, value):
    
    match statName:
        "numEnemiesSpawned":
            if not active and value >= activation_level:
                %Hole.set_surface_override_material(0, spawnerHoleActiveMaterial)
                activate()
                nextSpawnLoop()
                Post.statChanged.disconnect(statChanged)
    
func startLevel():

    velocity = velocity_initial
    mass     = mass_initial
    
    if spawnedBody: 
        spawnedBody.free()
        spawnedBody = null

func nextSpawnLoop():    
    
    assert(spawnedBody == null)
    spawnedBody = spawnee.instantiate()
    spawnedBody.collision_layer = 0
    spawnedBody.freeze = true
    spawnedBody.setMass(mass)
    spawnedBody.process_mode = Node.PROCESS_MODE_DISABLED
    
    if enemies.get_child_count() > 2000:
        Log.log("too many enemies!", enemies.get_child_count())
        for i in range(5):
            if enemies.get_child_count() > 2000:
                enemies.get_child(0).queue_free()
        Log.log("too many enemies?", enemies.get_child_count())
    
    enemies.add_child(spawnedBody)
    
    spawnedBody.global_position = %SpawnPoint.global_position
    
    mass     += mass_increment
    mass      = minf(mass, mass_max)
    velocity += velocity_increment
    velocity  = minf(velocity, velocity_max)
    
    %Body.scale  = spawnedBody.scale
    %Hole.scale  = spawnedBody.scale
    %IdentRing.position.x = maxf(2.0, 1.2 * spawnedBody.scale.x)
    
func clockFactor(factor):
    
    if not active: return
        
    if factor < 1/6.0:
        %Body.global_position.y = lerpf(1.2*%Body.scale.x, -1.2*%Body.scale.x, factor/(1.0/6.0))
    else:
        if not spawnedBody:
            nextSpawnLoop()

        var spawnFactor = (factor-1.0/6.0)/(5.0/6.0)
        %Body.global_position.y = lerpf(-1.2*%Body.scale.x, 1.2*%Body.scale.x, spawnFactor)
        spawnedBody.global_position = %SpawnPoint.global_position
        spawnedBody.global_position += curve.sample(spawnFactor) * %SpawnPoint.global_basis.x.normalized() * %Body.scale.x

func clockTick():
    
    if not active: return
    if not spawnedBody: return
    #Log.log("velocity", velocity)
    spawnedBody.setMass(mass)
    spawnedBody.global_position.y = 1.2*%Body.scale.x
    spawnedBody.collision_layer = Layer.LayerEnemy
    spawnedBody.freeze = false
    spawnedBody.process_mode = Node.PROCESS_MODE_PAUSABLE
    spawnedBody.apply_central_impulse(%SpawnPoint.global_basis.x.normalized() * velocity*mass)
    spawnedBody.spawned = true
    spawnedBody = null
    
    Post.enemySpawned.emit()
    Post.gameSound.emit(self, "enemySpawned", float(ident))
