extends Node3D

@export_range(2.0, 20.0, 0.1) var radius = 10
var corpses:Array[Enemy]

func _ready():
    
    setRadius(radius)
    Post.subscribe(self)
    
func setRadius(r:float):
    
    radius = r
    %Light.position.y = radius
    %Light.omni_range = sqrt(radius*radius + radius*radius)
    %Light.light_energy = 2.0 #+ radius * 0.06
        
    %Shape.shape.radius = radius
    %Mesh.mesh.size = Vector2(radius*2, radius*2)

func _physics_process(delta:float):
    
    if not is_inside_tree(): return
    
    for corpse in corpses:
        if corpse == null or corpse.is_queued_for_deletion() or not corpse.is_inside_tree(): continue 
        var dir = global_position - corpse.global_position
        var dst = dir.length()
        if dst < 0.5:
            corpse.queue_free()
            corpses.erase(corpse)
            Post.corpseCollected.emit(self)
        else:
            var scl = lerpf(corpse.scale.x, 0.1, clampf(1.0-dst/radius, 0.0, 0.2)*delta)
            corpse.scale = Vector3(scl, scl, scl)
            corpse.apply_central_impulse(dir*delta*0.1)

func bodyEntered(body:Node3D):

    if body.is_in_group("enemy") and body.health <= 0:
        var corpse:RigidBody3D = body
        corpse.mass            = 0.01
        corpse.gravity_scale   = 0
        corpse.collision_mask  = Layer.LayerFloor
        corpse.linear_velocity = Vector3.ZERO
        corpses.append(corpse)

func onEnemyDied(enemy:Enemy):
    
    var dst = global_position.distance_to(enemy.global_position)
    if dst < radius:
        bodyEntered(enemy)
