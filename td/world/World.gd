extends Node

func _ready():
    
    %Saver.load()
    
func _input(event: InputEvent):
    
    if Input.is_action_just_pressed("pause"): togglePause(); return
    if Input.is_action_just_pressed("quit"):  quitGame();    return
    #if Input.is_action_just_pressed("save"): %Saver.save(); return
    #if Input.is_action_just_pressed("load"): %Saver.load(); return
    
    if event is InputEventKey and event.pressed:
        
        if event.as_text() in ["Ctrl+Shift+D", "Alt+Z"]:
            #Log.log("fake zen key", event.as_text())
            EngineDebugger.send_message("editor:shortcut", ["Ctrl+Shift+F11"])
                
        if  Input.is_key_pressed(KEY_CTRL) or \
            Input.is_key_pressed(KEY_META) or \
            Input.is_key_pressed(KEY_ALT):
            
            #Log.log("editor key", event.as_text())
            EngineDebugger.send_message("editor:shortcut", [event.as_text()])
            
func togglePause():
    
    if not get_tree().paused:
        pauseGame()
    else:
        resumeGame()
        
func pauseGame():
    
    get_tree().call_group("game", "gamePaused")
    get_tree().paused = true
    %PauseMenu.visible = true
           
func resumeGame():
    
    %PauseMenu.visible = false
    get_tree().paused = false
    get_tree().call_group("game", "gameResumed")
        
func quitGame():
    
    %Saver.save()
    get_tree().quit()
