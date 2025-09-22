class_name Bounds
extends Area3D

var outsideCorpses : Array[Enemy] = []

func _ready():
    
    Post.subscribe(self)
    process_mode = Node.PROCESS_MODE_PAUSABLE
    
func _physics_process(delta: float):
    
    if outsideCorpses.size():
        for corpse in outsideCorpses:
            if not corpse: continue
            corpse.apply_central_impulse(corpse.global_position.normalized() * -10)
            if isOutside(corpse):
                Log.log("-outsideCorpse", outsideCorpses.size())
                outsideCorpses.erase(corpse)
    
func enemyCorpsed(corpse:Enemy):
    
    if isOutside(corpse):
        outsideCorpses.append(corpse)
        Log.log("+outsideCorpse", outsideCorpses.size())
        
func isOutside(corpse:Enemy):
    
    var state = spaceState()
    assert(state)
    # get_world_3d().direct_space_state
    var query = PhysicsPointQueryParameters3D.new()
    query.collide_with_areas  = true
    query.collide_with_bodies = false
    query.collision_mask = Layer.LayerBounds
    query.position = corpse.global_position
    var infos = state.intersect_point(query)
    return infos.is_empty()
    
func spaceState():
    
    var space = PhysicsServer3D.area_get_space(get_rid())
    if not space: return null
    
    return PhysicsServer3D.space_get_direct_state(space)

func bodyExit(body: Node3D):
    
    if body is Enemy and body.dead():

        var state = spaceState()
        if state:
            var query = PhysicsRayQueryParameters3D.new()
            query.collide_with_areas  = true
            query.collide_with_bodies = false
            query.collision_mask = Layer.LayerBounds
            query.from = body.global_position
            query.to = body.global_position - body.linear_velocity * 10.0
            var intersection = state.intersect_ray(query)
            if intersection.has("normal"):
                body.linear_velocity = body.linear_velocity.bounce(intersection.normal)
                body.linear_velocity = body.linear_velocity.limit_length(25)
