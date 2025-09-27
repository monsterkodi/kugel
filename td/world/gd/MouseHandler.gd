extends Control

## mouse is hidden if no mouse event occurred in this time interval
@export var seconds = 4.0

var mouseLock : bool = true :
    set(v):
        mouseLock = v
        Log.log("mouseLock", v)
        if not mouseLock:
            showMouse()
            
var mouseHide : bool = true :
    set(v):
        mouseHide = v
        Log.log("mouseHide", v)
        if mouseHide:       hideMouse()
        elif not mouseLock: showMouse()    

func mouseCaptured(): return Input.mouse_mode == Input.MOUSE_MODE_CAPTURED
func captureMouse():  if mouseLock: Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
#func showMouse():     Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE); $HideTimer.stop()
func showMouse():     
    Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
    startTimer()
        
func hideMouse():     
    if mouseHide: 
        Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
    else:
        showMouse()

func _exit_tree(): showMouse()
    
func _gui_input(event: InputEvent):
    
    if event is InputEventMouseMotion:
        if not mouseCaptured():
            if not event.relative.is_zero_approx() and not event.velocity.is_zero_approx():
                showMouse()
                
func stopTimer(): $HideTimer.stop()     
func startTimer():
    stopTimer()
    if mouseHide:
        $HideTimer.start(seconds)

func _on_hide_timer_timeout():
    if not mouseCaptured(): hideMouse()
    
func _on_mouse_exited():  
    Log.log("MouseExit")
    stopTimer() 
    Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
    
func _on_mouse_entered(): 
    Log.log("MouseEnter")
    startTimer()

func gamePaused():        hideMouse()
func gameResumed():       captureMouse()
