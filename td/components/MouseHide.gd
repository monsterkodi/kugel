extends Control

## mouse is hidden if no mouse event occurred in this time interval
@export var seconds = 2.0

func _ready() -> void:
    
    Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
    
func _exit_tree() -> void:
    
    Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
    
func _unhandled_input(event: InputEvent) -> void:
    
    if event is InputEventMouse:
        Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
        $HideTimer.start(seconds)

func _on_hide_timer_timeout() -> void:
    
    var mp = get_viewport().get_mouse_position()
    var sz = get_viewport().get_visible_rect().size
    var dt = 100
    if mp.x > dt and mp.y > dt and mp.x < sz.x - dt and mp.y < sz.y - dt or mp.x == 0 and mp.y == 0:
        Log.log("MouseHide", mp, sz)
        Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
    
func _on_mouse_exited() -> void:
    Log.log("MOUSE EXAGT")
