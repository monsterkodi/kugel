extends Node

func _ready():
    
    %Builder.visible = false
    %PauseMenu.visible = false
    %BuildMenu.visible = false
    %Saver.load()
    
func _input(event: InputEvent):
    
    if Input.is_action_just_pressed("pause"): togglePause(); return
    if Input.is_action_just_pressed("build"): buildMode(); return
    if Input.is_action_just_pressed("quit"):  quitGame();    return
    #if Input.is_action_just_pressed("save"): %Saver.save(); return
    #if Input.is_action_just_pressed("load"): %Saver.load(); return
    
    if event is InputEventKey and event.pressed  and event.keycode and not event.is_echo():
        
        if event.as_text() in ["Ctrl+Shift+D", "Alt+Z"]:
            #Log.log("fake zen key", event.as_text())
            EngineDebugger.send_message("editor:shortcut", ["Ctrl+Shift+F11"])
        if event.keycode not in [KEY_CTRL, KEY_META, KEY_ALT, KEY_SHIFT]:        
            if  Input.is_key_pressed(KEY_CTRL) or \
                Input.is_key_pressed(KEY_META) or \
                Input.is_key_pressed(KEY_ALT) or \
                Input.is_key_pressed(KEY_SHIFT):
                
                var shortcut = event.as_text()
                #shortcut = shortcut.replace("Option", "Alt")
                #Log.log("editor key", shortcut, event)
                Log.log("editor key", shortcut)
                EngineDebugger.send_message("editor:shortcut", [shortcut])
            #else:
                #Log.log("unknown key", event.as_text(), Input.is_key_pressed(KEY_CTRL), Input.is_key_pressed(KEY_META), Input.is_key_pressed(KEY_ALT))

func buildMode():
    
    if not %BuildMenu.visible:
        toggleBuild()

func toggleBuild():
    
    if not get_tree().paused:
        if %Player.vehicle is RigidBody3D:
            %Player.vehicle.linear_velocity = Vector3.ZERO
        pauseGame()
        var trans:Transform3D = %Player.global_transform
        trans.origin.y = 0
        %Builder.appear(trans)
        %BuildMenu.showMenu()
        %Camera/Follow.target = %Builder.vehicle
    elif %BuildMenu.visible:
        %Camera/Follow.target = %Player
        %Builder.vanish()
        %BuildMenu.hideMenu()
        if %Player.vehicle is RigidBody3D:
            %Player.vehicle.linear_velocity = Vector3.ZERO
        resumeGame()
            
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

func onBuildItem(item):
    
    %Builder.loadGhost(item.name)
    
func onBuilderDone():
    pass
