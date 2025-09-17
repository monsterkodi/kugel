extends Area3D

func bodyExit(body: Node3D):
    
    if body is Enemy and body.dead():

        var space       = PhysicsServer3D.area_get_space(get_rid())
        var space_state = PhysicsServer3D.space_get_direct_state(space)
        if space_state:
            var rayParam    = PhysicsRayQueryParameters3D.new()
            rayParam.collide_with_areas  = true
            rayParam.collide_with_bodies = false
            rayParam.collision_mask = Layer.LayerBounds
            rayParam.from = body.global_position
            rayParam.to = body.global_position - body.linear_velocity * 10.0
            var intersection = space_state.intersect_ray(rayParam)
            if intersection.has("normal"):
                body.linear_velocity = body.linear_velocity.bounce(intersection.normal)
        
