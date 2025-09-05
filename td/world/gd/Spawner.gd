class_name Spawner
extends Node3D

@export var spawnee:Resource

@export var activation_level:int = 0

@export_range(1.0, 10.0,  1.0) var mass_initial       = 1.0
@export_range(0.0, 100,  0.1)  var velocity_initial   = 10.0
@export_range(0.0, 60,   0.1)  var seconds_initial    = 10.0

@export var mass_increment     = 0.1
@export var mass_max           = 100.0
@export var velocity_increment = 0.05
@export var velocity_max       = 10.0
@export var seconds_decrement  = 0.05
@export var seconds_min        = 4.0

@export var curve:Curve
            
var mass:float
var velocity:float
var seconds:float

var tween:Tween
var spawnedBody:RigidBody3D
            
func _ready():

    velocity = velocity_initial
    seconds  = seconds_initial
    mass     = mass_initial
    
    if activation_level == 0:
        nextSpawnLoop.call_deferred()
    else:
        Post.statChanged.connect(statChanged)
        %Body.position.y = -1.2

func statChanged(statName, value):
    
    match statName:
        "numEnemiesSpawned":
            if value >= activation_level:
                nextSpawnLoop()
                Post.statChanged.disconnect(statChanged)
    
func level_reset():
    
    if tween:
        tween.kill()
        tween = null
    if spawnedBody: 
        spawnedBody.queue_free()

func nextSpawnLoop():    
    
    tween = create_tween()
    tween.tween_property(%Body, "position:y", 1.1, seconds/Info.enemySpeed).from(-1.2*%Body.scale.x).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
    tween.parallel().tween_method(preSpawn, 0.0, 1.0, seconds/Info.enemySpeed)
    tween.tween_callback(ejectSpawnBody)

    spawnedBody = spawnee.instantiate()
    spawnedBody.freeze = true
    spawnedBody.setMass(mass)
    get_parent_node_3d().add_child(spawnedBody)
    preSpawn(0)
    
    mass     += mass_increment
    mass      = minf(mass, mass_max)
    velocity += velocity_increment
    velocity  = minf(velocity, velocity_max)
    seconds  -= seconds_decrement
    seconds   = maxf(seconds, seconds_min)
    
    %Body.scale = spawnedBody.scale
    %Hole.scale = spawnedBody.scale
    
func preSpawn(value):
    
    spawnedBody.global_position = %SpawnPoint.global_position
    spawnedBody.global_position += curve.sample(value) * %SpawnPoint.global_basis.x.normalized()

func ejectSpawnBody():

    if not spawnedBody: return
    
    spawnedBody.setMass(mass)
    spawnedBody.freeze = false
    spawnedBody.apply_central_impulse(%SpawnPoint.global_basis.x.normalized() * velocity*mass)
    spawnedBody = null
    
    Post.enemySpawned.emit(self)
    %enemySpawned.play()
    tween = create_tween()
    tween.tween_property(%Body, "position:y", -1, seconds/(6.0*Info.enemySpeed)).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_CUBIC)
    tween.tween_callback(nextSpawnLoop)
