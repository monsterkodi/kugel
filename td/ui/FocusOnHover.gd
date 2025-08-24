extends Node

func _ready():
    
    get_parent().connect("mouse_entered", onHover)
    get_parent().connect("focus_entered", onHover)
    get_parent().connect("focus_exited",  onLeave)
    
func onHover():
    
    get_parent().grab_focus()
    get_parent().button_pressed = true

func onLeave():

    get_parent().button_pressed = false
