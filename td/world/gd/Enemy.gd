class_name Enemy extends RigidBody3D

var health = 1.0
var damageAccum = 0.0
var spawned = false

func alive(): return health > 0
func dead():  return health <= 0

func die():
    
    %died.play(0.09)
    
    health = 0
    %Attraction.disable()
    get_tree().create_timer(2.0).connect("timeout", makeCorpse)
    
func getColor() -> Color:
    
    if dead(): return Color(0,0,0)
    var vl = clampf(linear_velocity.length(), 0.0 , 1.0)
    return Color(1.3, 1.5-vl*1.5, 0)
    
func makeCorpse():

    if collision_layer != Layer.LayerCorpse:
        collision_layer = Layer.LayerCorpse
        Post.enemyDied.emit(self)
    
func setMass(m:float):
    
    mass = maxf(m, 0.5)
    health = mass-0.5
    
    var r = pow(mass/4.1888, 1.0/3.0)
    scale = Vector3(r, r, r)

func level_reset():
    
    die()
    makeCorpse()
    
func _integrate_forces(state: PhysicsDirectBodyState3D):
    
    for i in range(get_contact_count()):
        var collider:PhysicsBody3D = state.get_contact_collider_object(i)
        if collider and collider.collision_layer != Layer.LayerFloor:
            var damage = minf(state.get_contact_impulse(i).length()*0.1, 1.5)
            applyDamage(damage, collider)
            
    if damageAccum:
        applyDamage(damageAccum, null)
        damageAccum = 0
            
    if health <= 0:
        if global_position.length_squared() > 2500:
            linear_velocity = linear_velocity.bounce(-global_position.normalized())

func addDamage(damage:float):
    
    damageAccum += damage

func applyDamage(damage:float, source:PhysicsBody3D):
    
    if alive():
        setMass(mass-damage)
        
        if health <= 0:
            die()
            
    if source is Bullet:
        %hit.play()
        source.queue_free()
            
