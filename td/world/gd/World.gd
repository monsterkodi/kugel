class_name World
extends Node

const LEVEL   = preload("uid://wo631fluqa0p")
const LEVEL_B = preload("uid://btl7cihfnbl6u")

var currentLevel:Node3D
var currentLevelRes:PackedScene

func _ready():
    
    %MenuHandler.hideAllMenus()
    
    Post.subscribe(self)
    
    Info.player = %Player

    loadGame()
    mainMenu()
    
func mainMenu():
    
    get_tree().paused = true
    if currentLevel and Saver.savegame:
        currentLevel.saveLevel(Saver.savegame.data)
    %MenuHandler.appear(%MainMenu)
    
func _process(delta: float):
    pass
    #var orphan = Node.get_orphan_node_ids()
    #if not orphan.is_empty():
        #Node.print_orphan_nodes()
        #Log.log("orphans")
        ##quitGame()
        
func _unhandled_input(event: InputEvent):
    
    if Input.is_action_just_pressed("pause"): pauseMenu();   return
    if Input.is_action_just_pressed("build"): buildMode();   return
    if Input.is_action_just_pressed("quit"):  quitGame();    return
    #if Input.is_action_just_pressed("save"): Saver.save();  return
    #if Input.is_action_just_pressed("load"): Saver.load();  return
    
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
    
func enemySpawned(spawner:Spawner):
    
    #Log.log("level", %Player.cardLevel, "next in", %Player.nextCardIn)
    
    %Player.nextCardIn -= 1
    if %Player.nextCardIn <= 0:
        %Player.cardLevel += 1
        %Player.nextCardIn = Info.nextCardAtLevel(%Player.cardLevel)
        Log.log("cardLevel", %Player.cardLevel, %Player.nextCardIn)
        if %Player.cardLevel <= Info.maxCardLevel:
            pauseGame()
            #Log.log("level", %Player.cardLevel, "next in", %Player.nextCardIn)
            %MenuHandler.showCardChooser(Info.nextSetOfCards())
        else:
            var cardRes = Card.resWithName(Card.Money)
            Log.log("money level reached!", %Player.cardLevel, Info.maxCardLevel)
            Wallet.addPrice(cardRes.data.amount)

func cardSold(card:Card):
    
    if card.isPermanent():
        %Player.perm.delCard(card)
        %Player.cardLevel -= 1
        %Player.nextCardIn = clamp(%Player.nextCardIn, 0, Info.nextCardAtLevel(%Player.cardLevel))

func cardChosen(card:Card):
        
    if %Player.hand.get_child_count() < Info.battleCardSlots() and card.isBattleCard():
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

func newGame():
    
    Saver.clear()
    %Player.perm.addCard(Card.withName(Card.BattleCard))
    
func restartLevel():
    
    pauseGame()
    %MenuHandler.appear(%HandChooser)

func handChosen():

    loadLevel(currentLevelRes)
        
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
    %MenuHandler.slideOutRight(%BattleCards)
    
    get_tree().call_group("game", "gamePaused")
    get_tree().paused = true
           
func resumeGame():
    
    %MenuHandler.vanishActive()
    
    %MenuHandler.slideInTop(%Hud)
    %MenuHandler.slideInRight(%BattleCards)
    
    get_tree().paused = false
    get_tree().call_group("game", "gameResumed")
        
func quitGame():
    
    Saver.save()
    get_tree().quit()
        
func saveGame():
    
    Saver.save()
    
func loadGame():
    
    Saver.load()
    ensureOneBattleCard()
    
func settings(backMenu:Menu):
    
    %SettingsMenu.backMenu = backMenu
    %MenuHandler.appear(%SettingsMenu)

func ensureOneBattleCard():
    
    if Info.numberOfCardsOwned(Card.BattleCard) < 1:
        %Player.perm.addCard(Card.withName(Card.BattleCard))

func playLevel(levelRes):
    
    currentLevelRes = levelRes
    if %Player.deck.get_child_count():
        %MenuHandler.appear(%HandChooser)
    else:
        loadLevel(levelRes)

func loadLevel(levelRes):
    
    Log.log("loadLevel", levelRes)
    if currentLevel:
        saveGame()
        currentLevel.free()
    currentLevelRes = levelRes
    Log.log("level instantiate")
    currentLevel = levelRes.instantiate()
    currentLevel.inert = false
    Log.log("level add")
    add_child(currentLevel)
    Log.log("level start")
    currentLevel.start()
    Log.log("emit startLevel")
    Post.startLevel.emit()
    Log.log("emit applyCards")
    Post.applyCards.emit()
    Log.log("emit levelStart")
    Post.levelStart.emit()
    
    if Saver.savegame and Saver.savegame.data.has("Level") and Saver.savegame.data.Level.has(currentLevel.name):
        if Saver.savegame.data.Level[currentLevel.name]:
            Log.log("late load level")
            currentLevel.loadLevel(Saver.savegame.data)
    
    resumeGame()
