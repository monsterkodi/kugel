class_name World
extends Node

var currentLevelName : String
var currentLevel     : Level
var currentLevelRes  : PackedScene
     
func _ready():
    
    %MenuHandler.hideAllMenus()
    
    Post.subscribe(self)
    
    Settings.apply(Settings.defaults)

    loadGame()
    
    %SplashScreen.visible = true
    %MenuHandler.activeMenu = %SplashScreen
    %MusicHandler.playMenuMusic()
        
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
                
func baseDestroyed():
    
    if %SplashScreen.visible: 
        %SplashScreen.loadLevel()
        return
    
    pauseGame()
    Post.levelEnd.emit()
    currentLevel.save(Saver.savegame.data)
    %MenuHandler.appear(%ResultMenu)

func chooseCard():
    
    var cards = currentLevel.cards
    if cards.cardLevel <= Info.maxCardLevel:
        pauseGame()
        %MenuHandler.showCardChooser(cards.nextSetOfCards())
    else:
        var cardRes = Card.resWithName(Card.Money)
        Log.log("money level reached!", cards.cardLevel, Info.maxCardLevel)
        Wallet.addPrice(cardRes.data.amount)
    
func enemySpawned():
    
    if %SplashScreen.visible: return
    
    var cards = currentLevel.cards
    cards.nextCardIn -= 1
    
    if cards.nextCardIn <= 0:
        Post.preChooseAnim.emit()
        cards.cardLevel += 1
        cards.nextCardIn = cards.nextCardAtLevel()

func cardSold(card:Card):
    
    if card.isPermanent():
        var cards = currentLevel.cards
        cards.perm.delCard(card)
        cards.cardLevel -= 1
        cards.nextCardIn = clamp(cards.nextCardIn, 0, cards.nextCardAtLevel())

func cardChosen(card:Card):
        
    var cards = currentLevel.cards
    
    if card.isPermanent():
        cards.perm.addCard(card)
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
        cards.deck.addCard(card)
        cards.battle.addCard(Card.withName(card.res.name))
        
    Post.applyCards.emit()
    
    Saver.save()
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
    
func clearLevel():
    Log.log("clearLevel", currentLevel)
    if currentLevel:
        currentLevel.clear(Saver.savegame.data)
        Saver.save()
        currentLevel.free()

func retryLevel():
    
    loadLevel(currentLevelRes)
    
func playLevel(levelRes):
    
    loadLevel(levelRes)
        
func handChosen():
    
    var cards = currentLevel.cards

    cards.battle.clear()
    for card in cards.hand.get_children():
        cards.battle.addCard(Card.withName(card.res.name))
        
    Post.levelStart.emit()
    resumeGame()

func loadLevel(levelRes):
    
    currentLevelRes = levelRes
    currentLevel = levelRes.instantiate()
    currentLevel.inert = false
    currentLevelName = currentLevel.name
    add_child(currentLevel)
    currentLevel.start()
    Post.startLevel.emit()
    
    var isFresh = true
    if Saver.savegame.data.has("Level") and Saver.savegame.data.Level.has(currentLevel.name):
        if Saver.savegame.data.Level[currentLevel.name]:
            currentLevel.loadLevel(Saver.savegame.data)
            isFresh = not Saver.savegame.data.Level[currentLevel.name].has("gameTime")
            Post.levelLoaded.emit()

    Post.applyCards.emit()
    
    if isFresh and (currentLevel.cards.deck.get_child_count() or currentLevel.cards.hand.get_child_count()):
        %MenuHandler.appear(%HandChooser)
    else:
        Post.levelStart.emit()
        resumeGame()

func saveLevel():
    
    if currentLevel:
        
        currentLevel.save(Saver.savegame.data)
        saveGame()
        Post.levelSaved.emit(currentLevel.name)
        currentLevel.free()
