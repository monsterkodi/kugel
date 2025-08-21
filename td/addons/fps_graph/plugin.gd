@tool
extends EditorPlugin

func _enter_tree() -> void:
    add_autoload_singleton("fps_graph", "res://addons/fps_graph/fps_graph.tscn")

func _exit_tree() -> void:
    remove_autoload_singleton("fps_graph")
