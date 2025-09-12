class_name Spawner
extends Node3D

@export var spawnee:Resource

@export var activation_level:int = 0

@export_range(1.0, 10.0,  1.0) var mass_initial       = 1.0
@export_range(0.0, 100,  0.1)  var velocity_initial   = 10.0

@export var mass_increment     = 0.2
@export var mass_max           = 500.0
@export var velocity_increment = 0.025
@export var velocity_max       = 75.0

@export var curve:Curve
            
var mass        : float
var velocity    : float

var spawnedBody : RigidBody3D
var world       : World
var active      = false

const spawnerHolePassiveMaterial = preload("uid://djrtyqmjy623u")
const spawnerHoleActiveMaterial  = preload("uid://chltotc0ohct")
                                                
func _ready():

    world = get_node("/root/World")
    
    velocity = velocity_initial
    mass     = mass_initial
    
    Post.subscribe(self)
    
    var sf = 0.62
    var sc = Vector3(sf, sf, sf)
    %Body.scale = sc
    %Hole.scale = sc
    %Body.position.y = -sf*1.4
    
    if activation_level == 0:
        activate()
        %Hole.set_surface_override_material(0, spawnerHoleActiveMaterial)
    else:
        %Hole.set_surface_override_material(0, spawnerHolePassiveMaterial)

func activate():
    
    active = true
    Post.spawnerActivated.emit()

func statChanged(statName, value):
    
    match statName:
        "numEnemiesSpawned":
            if value >= activation_level:
                %Hole.set_surface_override_material(0, spawnerHoleActiveMaterial)
                activate()
                nextSpawnLoop()
                Post.statChanged.disconnect(statChanged)
    
func levelStart():

    velocity = velocity_initial
    mass     = mass_initial
    
    if spawnedBody: 
        spawnedBody.free()
        spawnedBody = null

func nextSpawnLoop():    
    
    spawnedBody = spawnee.instantiate()
    spawnedBody.collision_layer = 0
    spawnedBody.freeze = true
    spawnedBody.setMass(mass)

    world.currentLevel.get_node("Enemies").add_child(spawnedBody)
    
    mass     += mass_increment
    mass      = minf(mass, mass_max)
    velocity += velocity_increment
    velocity  = minf(velocity, velocity_max)
    
    #Log.log("mass", mass, "vel", velocity, "scale", spawnedBody.scale.x)
    
    %Body.scale = spawnedBody.scale
    %Hole.scale = spawnedBody.scale
    
func clockFactor(factor):
    
    if not active: return
        
    if factor < 1/6.0:
        %Body.global_position.y = lerpf(1.2*%Body.scale.x, -1.2*%Body.scale.x, factor/(1.0/6.0))
        #%Body.scale = spawnedBody.scale
    else:
        if not spawnedBody:
            nextSpawnLoop()

        var spawnFactor = (factor-1.0/6.0)/(5.0/6.0)
        %Body.scale = spawnedBody.scale
        %Body.global_position.y = lerpf(-1.2*%Body.scale.x, 1.2*%Body.scale.x, spawnFactor)
        spawnedBody.global_position = %SpawnPoint.global_position
        spawnedBody.global_position += curve.sample(spawnFactor) * %SpawnPoint.global_basis.x.normalized()

func clockTick():
    
    if not active: return
    if not spawnedBody: return
    
    spawnedBody.setMass(mass)
    spawnedBody.collision_layer = Layer.LayerEnemy
    spawnedBody.freeze = false
    spawnedBody.apply_central_impulse(%SpawnPoint.global_basis.x.normalized() * velocity*mass)
    spawnedBody.spawned = true
    spawnedBody = null
    
    Post.enemySpawned.emit(self)
    %enemySpawned.play()
