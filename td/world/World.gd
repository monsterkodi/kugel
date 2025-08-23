extends Node

func _ready():
    
    %Saver.load()
    
func _input(event: InputEvent):
    
    if Input.is_action_just_pressed("pause"): togglePause(); return
    if Input.is_action_just_pressed("build"): toggleBuild(); return
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

func toggleBuild():
    
    if not get_tree().paused:
        pauseGame()
        %BuildMenu.showMenu()
    elif %BuildMenu.visible:
        resumeGame()
        %BuildMenu.hideMenu()
            
func togglePause():
    
    if not get_tree().paused:
        pauseGame()
        %PauseMenu.visible = true
    elif %PauseMenu.visible:
        %PauseMenu.visible = false
        resumeGame()
        
func pauseGame():
    
    get_tree().call_group("game", "gamePaused")
    get_tree().paused = true
           
func resumeGame():
    
    get_tree().paused = false
    get_tree().call_group("game", "gameResumed")
        
func quitGame():
    
    %Saver.save()
    get_tree().quit()
