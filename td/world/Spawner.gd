extends Node3D

@export var spawnee:Resource
@export_range(1.0, 100,  1.0)   var enemy_health_initial   = 10.0
@export_range(1.0, 10.0, 0.1)   var enemy_health_increment = 1.0
@export_range(0.0, 100,  0.1)   var velocity_initial       = 10.0
@export_range(0.0, 60,   0.1)   var seconds_initial        = 10.0
@export_range(0.0, 0.1,  0.001) var velocity_increment     = 0.01
@export_range(0.0, 0.1,  0.001) var seconds_decrement      = 0.01

@export var curve:Curve
            
var velocity:float
var seconds:float
            
var enemyHealth:float
var tween:Tween
var spawnedBody:RigidBody3D
            
func _ready():

    velocity    = velocity_initial
    seconds     = seconds_initial
    enemyHealth = enemy_health_initial
    
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
    spawnedBody.maxHealth = enemyHealth
    %SpawnPoint.add_child(spawnedBody)
    spawnedBody.freeze = true
    
    enemyHealth += enemy_health_increment
    velocity    += velocity_increment
    seconds     -= seconds_decrement
    
func preSpawn(value): 
    
    spawnedBody.position.x = curve.sample(value)

func ejectSpawnBody():

    if not spawnedBody: return
    
    spawnedBody.get_parent().remove_child(spawnedBody)
    get_parent_node_3d().add_child(spawnedBody)
    spawnedBody.position = Vector3.ZERO
    spawnedBody.global_transform = %SpawnPoint.global_transform
    spawnedBody.apply_central_impulse(%SpawnPoint.transform.basis.z * -velocity)
    spawnedBody.freeze = false
    spawnedBody = null
    
    Post.enemySpawned.emit()
    
    tween = get_tree().create_tween()
    tween.tween_property(%Body, "position:y", -1, 1.5).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_CUBIC)
    tween.tween_callback(nextSpawnLoop)
