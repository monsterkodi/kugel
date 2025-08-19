extends RigidBody3D

func level_reset(): despawn()
func despawn(): get_parent_node_3d().remove_child(self)
