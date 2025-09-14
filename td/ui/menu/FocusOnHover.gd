class_name FocusOnHover
extends Node

func _ready():
    
    get_parent().connect("mouse_entered", onHover)
    get_parent().connect("focus_entered", onHover)
    get_parent().connect("focus_exited",  onLeave)
    
func onHover():
    
    get_parent().grab_focus()
    if get_parent() is Button:
        get_parent().button_pressed = true

func onLeave():

    if get_parent() is Button:
        get_parent().button_pressed = false
