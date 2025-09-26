class_name BlenderMesh
extends Node3D

@export var material : Material :
    set(v): get_child(0).set_surface_override_material(0, v)
    get():  return get_child(0).get_surface_override_material(0)
    
