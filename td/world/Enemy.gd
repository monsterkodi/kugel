class_name Enemy extends RigidBody3D

var mat:StandardMaterial3D
@export var maxHealth = 10.0
var health = maxHealth

func _ready() -> void:
    
    health = maxHealth
    #Log.log("enemy", health)
    mat = $Mesh.get_surface_override_material(0).duplicate()
    $Mesh.set_surface_override_material(0, mat)

func level_reset(): despawn()
func despawn(): queue_free()

func _physics_process(_delta: float) -> void:
    
    if health > 0:
        var vl = clampf(linear_velocity.length(), 0.0 , 1.0)
        mat.albedo_color = Color(1, 1-vl, 0)

func _integrate_forces(state: PhysicsDirectBodyState3D) -> void:
    
    for i in range(get_contact_count()):
        var collider:PhysicsBody3D = state.get_contact_collider_object(i)
        if collider and collider.collision_layer != Layer.LayerFloor:
            var damage = state.get_contact_impulse(i).length()
            #Log.log("damage", damage)
            applyDamage(damage, collider)
            
    if health <= 0:
        if global_position.length_squared() > 2200:
            #linear_velocity = Vector3.ZERO
            linear_velocity = linear_velocity.bounce(-global_position.normalized())

func applyDamage(damage:float, source:PhysicsBody3D):
    
    health -= damage
    
    if health <= 0:
        mat.albedo_color = Color(0, 0, 0)
        $Attraction.targetNode = null
        if source:# and source is Pill:
            var t:Timer = Timer.new()
            t.one_shot = true
            t.wait_time = 1
            t.connect("timeout", func():Post.enemyDied.emit(self))
            add_child(t)
            t.start()
        else:
            Post.enemyDied.emit(self)
    else:        
        var hf = 0.5 + 0.5 * health / maxHealth
        scale = Vector3(hf, hf, hf)
        
    if source is Bullet:
        source.queue_free()
            
