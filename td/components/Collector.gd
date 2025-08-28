extends Node3D

@export_range(2.0, 20.0, 0.1) var radius = 10
var corpses:Array[Enemy]

func _ready():
    
    %Light.position.y = radius
    %Light.omni_range = sqrt(radius*radius + radius*radius)
    %Light.light_energy = radius * 0.06
        
    %Shape.shape.radius = radius
    %Mesh.mesh.size = Vector2(radius*2, radius*2)
    Post.enemyDied.connect(onEnemyDied)

func _physics_process(delta:float):
    
    for corpse in corpses:
        if corpse == null or corpse.is_queued_for_deletion(): continue 
        var dir = global_position - corpse.global_position
        var dst = dir.length()
        if dst < 0.75:
            corpse.queue_free()
            corpses.erase(corpse)
            Post.corpseCollected.emit()
        else:
            var scl = clampf(dst/radius, 0, 1)
            corpse.scale = corpse.scale.limit_length(scl)
            corpse.apply_central_impulse(dir*delta)

func bodyEntered(body:Node3D):

    if body.is_in_group("enemy") and body.health <= 0:
        var corpse:RigidBody3D = body
        corpse.mass = 0.01
        corpse.gravity_scale   = 0
        #corpse.collision_layer = 0
        corpse.collision_mask  = Layer.LayerFloor
        corpse.linear_velocity = Vector3.ZERO
        var dir = global_position - corpse.global_position
        corpse.apply_central_impulse(dir*0.01)
        
        corpses.append(corpse)

func onEnemyDied(enemy:Enemy):
    
    var dst = global_position.distance_to(enemy.global_position)
    if dst < radius:
        bodyEntered(enemy)
