extends RigidBody3D

var mat:StandardMaterial3D
@export var maxHealth = 10.0
var health = maxHealth

func _ready() -> void:
    
    health = maxHealth
    Log.log("enemy", health)
    mat = $Mesh.get_surface_override_material(0).duplicate()
    $Mesh.set_surface_override_material(0, mat)

func level_reset(): despawn()
func despawn(): get_parent_node_3d().remove_child(self)

func _physics_process(_delta: float) -> void:
    
    if health > 0:
        var vl = clampf(linear_velocity.length(), 0.0 , 1.0)
        mat.albedo_color = Color(1, 1-vl, 0)

func _integrate_forces(state: PhysicsDirectBodyState3D) -> void:
    
    for i in range(get_contact_count()):
        var collider:PhysicsBody3D = state.get_contact_collider_object(i)
        if collider.collision_layer != Layer.Floor:
            var damage = state.get_contact_impulse(i).length()
            #Log.log("damage", damage)
            applyDamage(damage)

func applyDamage(damage:float):
    
    health -= damage
    
    if health <= 0:
        mat.albedo_color = Color(0, 0, 0)
        $Attraction.targetNode = null
        #if get_node("Attraction"):
            #remove_child($Attraction)
    else:        
        var hf = 0.5 + 0.5 * health / maxHealth
        scale = Vector3(hf, hf, hf)
            
