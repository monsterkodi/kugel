class_name World
extends Node
const LEVEL = preload("uid://wo631fluqa0p")

var currentLevel:Node3D

func _ready():
    
    %MenuHandler.hideAllMenus()
    
    Post.subscribe(self)
    
    Info.player = %Player
    
    %Saver.load()
    Post.startLevel.emit()
    
func _process(delta: float):
    
    var orphan = Node.get_orphan_node_ids()
    if not orphan.is_empty():
        Node.print_orphan_nodes()
        Log.log("orphans")
        quitGame()
        
func _unhandled_input(event: InputEvent):
    
    if Input.is_action_just_pressed("pause"): togglePause(); return
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

func threeRandomCards():
    
    var allCards:Array[CardRes] = Utils.allCardRes()
    var cards:Array[Card] = []
    while cards.size() < 3:
        var cardRes = allCards[randi_range(0, allCards.size()-1)]
        if cardRes.maxNum > 0:
            var cardCount = Info.numberOfCardsOwned(cardRes.name)
            if cardCount >= cardRes.maxNum:
                allCards.erase(cardRes)
                continue
        cards.append(Card.new(cardRes))
        if cardRes.maxNum > 0:
            allCards.erase(cardRes)
    return cards
            
func baseDestroyed():
    
    Post.levelEnd.emit()
    pauseGame()
    %MenuHandler.showCardChooser(threeRandomCards())
    
func enemySpawned():
    
    if (Stats.numEnemiesSpawned % 50) == 0:
        pauseGame()
        %MenuHandler.showCardChooser(threeRandomCards())

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
        
    %MenuHandler.slideIn(%Hud)
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
    %MenuHandler.slideIn(%Hud)
    Post.applyCards.emit()
    Post.levelStart.emit()
    resumeGame()
    
func restartLevel():
    
    pauseGame()
    %MenuHandler.appear(%HandChooser)
                  
func togglePause():
    
    if not get_tree().paused:
        pauseGame()
        %MenuHandler.appear(%PauseMenu)
    else:
        %MenuHandler.vanishActive()
        if %BuildMenu.visible:
            toggleBuild()
        else:
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
    
func saveGame():
    
    %Saver.save()
    
func loadGame():
    
    %Saver.load()
    
func settings():
    
    %MenuHandler.appear(%SettingsMenu)
