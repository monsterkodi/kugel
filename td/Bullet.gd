extends RigidBody3D

func level_reset(): despawn()
func despawn(): queue_free()
