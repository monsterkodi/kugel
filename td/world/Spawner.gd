extends Node3D

@export var spawnee:Resource
@export_range(1.0, 100,  1.0)  var mass_initial       = 1.0
@export_range(0.0, 100,  0.1)  var velocity_initial   = 2.0
@export_range(0.0, 60,   0.1)  var seconds_initial    = 10.0

@export var mass_increment     = 0.2
@export var velocity_increment = 0.05
@export var seconds_decrement  = 0.1

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
    
    nextSpawnLoop()

func level_reset():
    
    tween.kill()
    tween = null
    if spawnedBody: spawnedBody.queue_free()
    _ready()

func nextSpawnLoop():    
    
    tween = get_tree().create_tween()
    tween.tween_property(%Body, "position:y", 1.1, seconds).from(-1.2).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
    tween.parallel().tween_method(preSpawn, 0.0, 1.0, seconds)
    tween.tween_callback(ejectSpawnBody)

    spawnedBody = spawnee.instantiate()
    spawnedBody.setMass(mass)
    %SpawnPoint.add_child(spawnedBody)
    spawnedBody.freeze = true
    
    mass     += mass_increment
    velocity += velocity_increment
    seconds  -= seconds_decrement
    
func preSpawn(value): 
    
    spawnedBody.position.x = curve.sample(value)

func ejectSpawnBody():

    if not spawnedBody: return
    
    spawnedBody.get_parent().remove_child(spawnedBody)
    get_parent_node_3d().add_child(spawnedBody)
    spawnedBody.global_transform = %SpawnPoint.global_transform
    spawnedBody.setMass(mass)
    spawnedBody.freeze = false
    spawnedBody.apply_central_impulse(%SpawnPoint.global_basis.x * velocity*mass)
    spawnedBody = null
    
    Post.enemySpawned.emit()
    
    tween = get_tree().create_tween()
    tween.tween_property(%Body, "position:y", -1, 1.5).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_CUBIC)
    tween.tween_callback(nextSpawnLoop)
