extends Control

## mouse is hidden if no mouse event occurred in this time interval
@export var seconds = 2.0

func _ready() -> void:
    
    Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
    
func _exit_tree() -> void:
    
    Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
    
func _input(event: InputEvent) -> void:
    
    if event is InputEventMouse:
        Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
        $HideTimer.start(seconds)

func _on_hide_timer_timeout() -> void:
    
    Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
    
func _on_mouse_exited() -> void:
    
    $HideTimer.stop()
    Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

func _on_mouse_entered() -> void:
    
    $HideTimer.start(seconds)
