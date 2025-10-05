class_name Enemy extends RigidBody3D

var health      = 1.0
var damageAccum = 0.0
var spawned     = false

func alive(): return health > 0
func dead():  return health <= 0
var deadColor : Color = Color(0,0,0)

func _ready():
    
    Utils.level(self).get_node("MultiMesh").add("enemy", self)

func _exit_tree():
    
    Utils.level(self).get_node("MultiMesh").del("enemy", self)

func save() -> Dictionary:
    
    var dict = {}
    dict.health = health
    dict.mass   = mass
    dict.position = global_position
    dict.velocity = linear_velocity
    dict.angular  = angular_velocity
    return dict

func load(dict:Dictionary):
    
    spawned = true
    setMass(dict.mass)
    health = dict.health
    if health <= 0:
        collision_layer = Layer.LayerCorpse
        %Attraction.disable()
    else:
        collision_layer = Layer.LayerEnemy
    global_position  = dict.position
    linear_velocity  = dict.velocity
    angular_velocity = dict.angular 
    
func die():
    
    collision_layer = Layer.LayerDying
    health = 0
    %Attraction.disable()
    var tween = create_tween()
    tween.set_process_mode(Tween.TWEEN_PROCESS_PHYSICS)
    tween.set_ease(Tween.EASE_OUT)
    tween.set_trans(Tween.TRANS_QUINT)
    tween.tween_method(setMass, mass, 0.5, 1.0)
    tween.parallel().tween_method(func(v): deadColor = Color(v,0,0), 1.0, 0.0, 0.3)
    tween.tween_callback(makeCorpse)
    
    Post.enemyDied.emit(self)
    
func getColor() -> Color:
    
    if dead(): return deadColor
    var vl = clampf(linear_velocity.length(), 0.0 , 1.0)
    return Color(1.3, 1.5-vl*1.5, 0)
    
func makeCorpse():

    if collision_layer != Layer.LayerCorpse:
        collision_layer = Layer.LayerCorpse
        Post.enemyCorpsed.emit(self)
    
func setMass(m:float):
    
    mass  = maxf(m, 0.5)
    
    var r = pow(mass/4.1888, 1.0/3.0)
    scale = Vector3(r, r, r)

func level_reset():
    
    die()
    makeCorpse()
    
func _integrate_forces(state: PhysicsDirectBodyState3D):
    
    if global_position.y < -1.0:
        #Log.log("enemy below ground")
        queue_free()
        return
    if alive():
        for i in range(get_contact_count()):
            var collider:PhysicsBody3D = state.get_contact_collider_object(i)
            if collider and collider.collision_layer != Layer.LayerFloor:
                var damage = minf(state.get_contact_impulse(i).length()*0.1, 1.5)
                applyDamage(damage, collider)
                
        if damageAccum:
            applyDamage(damageAccum, null)
            damageAccum = 0
            
func addDamage(damage:float):
    
    damageAccum += damage

func applyDamage(damage:float, source:PhysicsBody3D):
    
    if alive():
        #%died.pitch_scale = 1.0 + (4.0 - minf(100.0, mass-0.5) / 25.0)
        setMass(mass-damage)
        health = mass-0.5
        if health <= 0:
            Post.gameSound.emit(self, "enemyDied")
            die()
            
    if source is Bullet:
        Post.gameSound.emit(self, "enemyHit")
        source.queue_free()
