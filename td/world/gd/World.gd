class_name World
extends Node

var currentLevel    : Level
var currentLevelRes : PackedScene
     
func _ready():
    
    %MenuHandler.hideAllMenus()
    
    Post.subscribe(self)
    
    Info.player = %Player

    #Log.log("apply defaults")
    Settings.apply(Settings.defaults)

    loadGame()
    
    Post.mainMenu.emit()
        
func mainMenu():
    
    get_tree().paused = true
    saveLevel()
    %MenuHandler.appear(%MainMenu)

func _process(delta: float):
    
    var orphan = Node.get_orphan_node_ids()
    if not orphan.is_empty():
        Node.print_orphan_nodes()
        Log.log("orphans")
        #quitGame()
        
func _unhandled_input(event: InputEvent):
    
    if Input.is_action_just_pressed("pause"): pauseMenu();   return
    if Input.is_action_just_pressed("build") and not get_tree().paused: buildMode();   return
    if Input.is_action_just_pressed("quit"):  quitGame();    return
    
    if Input.is_action_just_pressed("faster"): Info.fasterEnemySpeed()
    if Input.is_action_just_pressed("slower"): Info.slowerEnemySpeed()
    
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
    %MenuHandler.appear(%ResultMenu)
    resetLevel()

func chooseCard():
    
    #assert(%Player.nextCardIn <= 0)
        
    if %Player.cardLevel <= Info.maxCardLevel:
        pauseGame()
        #Log.log("level", %Player.cardLevel, "next in", %Player.nextCardIn)
        %MenuHandler.showCardChooser(Info.nextSetOfCards())
    else:
        var cardRes = Card.resWithName(Card.Money)
        Log.log("money level reached!", %Player.cardLevel, Info.maxCardLevel)
        Wallet.addPrice(cardRes.data.amount)
    
func enemySpawned():
    
    #Log.log("level", %Player.cardLevel, "next in", %Player.nextCardIn)
    
    %Player.nextCardIn -= 1
    
    if %Player.nextCardIn <= 0:
        Post.preChooseAnim.emit()
        %Player.cardLevel += 1
        %Player.nextCardIn = Info.nextCardAtLevel(%Player.cardLevel)

    #Log.log("cardLevel", %Player.cardLevel, %Player.nextCardIn)

func cardSold(card:Card):
    
    if card.isPermanent():
        %Player.perm.delCard(card)
        %Player.cardLevel -= 1
        %Player.nextCardIn = clamp(%Player.nextCardIn, 0, Info.nextCardAtLevel(%Player.cardLevel))

func cardChosen(card:Card):
        
    if card.isPermanent():
        %Player.perm.addCard(card)
        if card.res.name == Card.ShieldLayer:
            var shield = currentLevel.firstPlacedBuildingOfType("Shield")
            if shield: shield.addLayer()
    elif card.isOnce():
        if card.res.name == "Money":
            Wallet.addPrice(card.res.data.amount)
        else:
            Log.log("???", card.res.name)
    else:
        assert(card.isBattleCard())
        %Player.deck.addCard(card)
        var battleCard = Card.withName(card.res.name)
        Log.log("add battle card", battleCard.res.name, battleCard.lvl)
        %Player.battle.addCard(battleCard, false)
        
    Post.applyCards.emit()
    
    resumeGame()

func newGame():
    
    Saver.clear()
        
func buildMode():
    
    pauseGame()
    %MenuHandler.slideOutRightTween.stop()
    %MenuHandler.appear(%BuildMenu, "left")
                  
func pauseMenu():
    
    if not get_tree().paused:
        pauseGame()
        %MenuHandler.appear(%PauseMenu)
        
func pauseGame():
    
    %MenuHandler.slideOutTop(%Hud)
    %MenuHandler.slideOutBottom(%HudClock)
    %MenuHandler.slideOutRight(%BattleCards)
    
    get_tree().call_group("game", "gamePaused")
    get_tree().paused = true
    Post.gamePaused.emit()
           
func resumeGame():
    
    %MenuHandler.vanishActive()
    
    %MenuHandler.slideInTop(%Hud)
    %MenuHandler.slideInBottom(%HudClock)
    %MenuHandler.slideInRight(%BattleCards)
    
    get_tree().paused = false
    get_tree().call_group("game", "gameResumed")
    Post.gameResume.emit()
        
func quitGame():
    
    Saver.save()
    get_tree().quit()
        
func saveGame():
    
    Saver.save()
    
func loadGame():
    
    Saver.load()
    
func settings(backMenu:Menu):
    
    %SettingsMenu.backMenu = backMenu
    %MenuHandler.appear(%SettingsMenu)

func restartLevel():
    
    Log.log("restartLevel")
    clearLevel()
    saveGame()
    loadLevel(currentLevelRes)
    
func clearLevel():
    Log.log("clearLevel", currentLevel)
    if currentLevel:
        #currentLevel.clearLevel(Saver.savegame.data)
        currentLevel.resetLevel(Saver.savegame.data)
        currentLevel.free()

func resetLevel():
    Log.log("resetLevel", currentLevel)
    if currentLevel:
        Post.levelReset.emit()
        currentLevel.free()

func retryLevel():
    
    loadLevel(currentLevelRes)
    
func playLevel(levelRes):
    
    loadLevel(levelRes)
        
func handChosen():

    for card in %Player.hand.get_children():
        %Player.battle.addCard(Card.withName(card.res.name), false)
        
    Post.levelStart.emit()
    resumeGame()

func loadLevel(levelRes):
    
    Log.log("loadLevel", levelRes)

    currentLevelRes = levelRes
    #Log.log("level instantiate")
    currentLevel = levelRes.instantiate()
    currentLevel.inert = false
    #Log.log("level add")
    add_child(currentLevel)
    #Log.log("level start")
    currentLevel.start()
    #Log.log("emit startLevel")
    Post.startLevel.emit()
    
    var isFresh = true
    if Saver.savegame.data.has("Level") and Saver.savegame.data.Level.has(currentLevel.name):
        if Saver.savegame.data.Level[currentLevel.name]:
            Log.log("late load level")
            currentLevel.loadLevel(Saver.savegame.data)
            isFresh = not Saver.savegame.data.Level[currentLevel.name].has("gameTime")
            Post.levelLoaded.emit()

    #Log.log("emit applyCards")
    Post.applyCards.emit()
    #Log.log("emit levelStart")
    
    if isFresh and %Player.deck.get_child_count():
        %MenuHandler.appear(%HandChooser)
    else:
        Post.levelStart.emit()
        resumeGame()

func saveLevel():
    
    if currentLevel:
        Log.log("save and free current level", currentLevel)
        
        currentLevel.saveLevel(Saver.savegame.data)
        saveGame()
            
        currentLevel.free()
