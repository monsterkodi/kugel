class_name World
extends Node
const LEVEL = preload("uid://wo631fluqa0p")

var currentLevel:Node3D

func _ready():
    
    %MenuHandler.hideAllMenus()
    
    Post.subscribe(self)
    
    Info.player = %Player
    
    loadGame()
    Post.startLevel.emit()
    
func _process(delta: float):
    
    var orphan = Node.get_orphan_node_ids()
    if not orphan.is_empty():
        Node.print_orphan_nodes()
        Log.log("orphans")
        quitGame()
        
func _unhandled_input(event: InputEvent):
    
    if Input.is_action_just_pressed("pause"): pauseMenu();   return
    if Input.is_action_just_pressed("build"): buildMode();   return
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
                Input.is_key_pressed(KEY_ALT)  or \
                Input.is_key_pressed(KEY_SHIFT):
                
                var shortcut = event.as_text()
                #shortcut = shortcut.replace("Option", "Alt")
                #Log.log("editor key", shortcut)
                EngineDebugger.send_message("editor:shortcut", [shortcut])
            #else:
                #Log.log("unknown key", event.as_text(), Input.is_key_pressed(KEY_CTRL), Input.is_key_pressed(KEY_META), Input.is_key_pressed(KEY_ALT))
            
func baseDestroyed():
    
    Post.levelEnd.emit()
    pauseGame()
    %MenuHandler.appear(%HandChooser)
    
func enemySpawned(spawner:Spawner):
    
    Log.log("level", %Player.cardLevel, "next in", %Player.nextCardIn)
    
    %Player.nextCardIn -= 1
    if %Player.nextCardIn <= 0:
        pauseGame()
        %Player.cardLevel += 1
        %Player.nextCardIn = Info.nextCardAtLevel(%Player.cardLevel)
        Log.log("level", %Player.cardLevel, "next in", %Player.nextCardIn)
        %MenuHandler.showCardChooser(Info.nextSetOfCards())

func cardChosen(card:Card):
        
    if %Player.hand.get_child_count() < Info.maxHandCards() and card.isBattleCard():
        %Player.hand.addCard(card)
    elif card.isPermanent():
        %Player.perm.addCard(card)
    elif card.isOnce():
        if card.res.name == "Money":
            Wallet.addPrice(card.res.data.amount)
    else:
        assert(card.isBattleCard())
        %Player.deck.addCard(card)
        
    Post.applyCards.emit()
    
    resumeGame()
       
func handChosen():

    Post.startLevel.emit()
    
func startLevel():
    
    Log.log("startLevel")
    if currentLevel:
        currentLevel.queue_free()
    currentLevel = LEVEL.instantiate()
    add_child(currentLevel)
    
    Post.applyCards.emit()
    Post.levelStart.emit()
    
    resumeGame()
    
func restartLevel():
    
    pauseGame()
    %MenuHandler.appear(%HandChooser)

func newGame():
    
    %Saver.clear()
    restartLevel()
    
func buildMode():
    
    pauseGame()

    %MenuHandler.appear(%BuildMenu, "left")
                  
func pauseMenu():
    
    if not get_tree().paused:
        pauseGame()
        %MenuHandler.appear(%PauseMenu)
        
func pauseGame():
    
    %MenuHandler.slideOut(%Hud)
    
    get_tree().call_group("game", "gamePaused")
    get_tree().paused = true
           
func resumeGame():
    
    %MenuHandler.vanishActive()
    %MenuHandler.slideIn(%Hud)
    
    get_tree().paused = false
    get_tree().call_group("game", "gameResumed")
        
func quitGame():
    
    %Saver.save()
    get_tree().quit()
        
func saveGame():
    
    %Saver.save()
    
func loadGame():
    
    %Saver.load()
    
func settings():
    
    %MenuHandler.appear(%SettingsMenu)
