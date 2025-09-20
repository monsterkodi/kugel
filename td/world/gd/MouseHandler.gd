extends Control

## mouse is hidden if no mouse event occurred in this time interval
@export var seconds = 4.0

func mouseCaptured(): return Input.mouse_mode == Input.MOUSE_MODE_CAPTURED
func captureMouse():  Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
func showMouse():     Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE); $HideTimer.stop()
func hideMouse():     Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)

func _ready():     pass
func _exit_tree(): showMouse()
    
func _input(event: InputEvent):
    
    if event is InputEventMouseMotion:
        if not mouseCaptured():
            if not event.relative.is_zero_approx() and not event.velocity.is_zero_approx():
                showMouse()
                startTimer()
            
func startTimer():
    #if not get_tree().paused:
    #$HideTimer.start(seconds)
    pass

func _on_hide_timer_timeout():
    if not mouseCaptured(): hideMouse()
    
#func _on_mouse_entered(): startTimer()
func gamePaused():        hideMouse()
func gameResumed():       captureMouse()
