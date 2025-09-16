extends Area3D

func bodyExit(body: Node3D):
    
    if body is Enemy and body.dead():
        #body.linear_velocity = body.linear_velocity.bounce(-body.global_position.normalized())
        #body.linear_velocity *= 0.9  
        body.linear_velocity  = Vector3.ZERO
        body.angular_velocity = Vector3.ZERO
