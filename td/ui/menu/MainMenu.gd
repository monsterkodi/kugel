class_name MainMenu
extends Menu

signal playLevel

@onready var levelButtons: HBoxContainer = %LevelButtons

func onQuit():      if is_processing_input(): Post.quitGame.emit()
func onSettings():  if is_processing_input(): Post.settings.emit(self)
func onHelp():      if is_processing_input(): %HelpMenu.backMenu = self; %MenuHandler.appear(%HelpMenu)
func onCredits():   if is_processing_input(): %MenuHandler.appear(%CreditsMenu)
func onNewGame():   if is_processing_input(): Post.newGame.emit()

const LEVEL_BUTTON = preload("uid://thwlxijax7nj")
const LEVEL_SIZE   = Vector2i(550,400)

var lastFocused = null

func _ready():
    
    Post.subscribe(self)
    super._ready()
    
func levelSaved(levelName):
    
    #Log.log("mainMenu.levelSaved", levelName)
    var index = 0
    var scene = null
    match levelName:
        "Linea":     index = 0; scene = load("uid://btl7cihfnbl6u")
        "Circulus":  index = 1; scene = load("uid://wo631fluqa0p")
        "Quadratum": index = 2; scene = load("uid://0ilo4a8dvk77")
        
    if scene:
        var button = levelButtons.get_child(index)    
        button.setScene(scene)
        var level = button.viewport.scene.get_child(-1)
        if level is Level:
            level.showBuildSlots()
        button.levelInfo(levelName)

func back(): 
    
    if %Quit.has_focus():
        Post.quitGame.emit()
    else:
        %Quit.grab_focus()
    
func appear():

    if levelButtons.get_child_count() == 0:
        
        var button1 : Button = addLevelButton(load("uid://btl7cihfnbl6u"))
        var button2 : Button = addLevelButton(load("uid://wo631fluqa0p"))
        var button3 : Button = addLevelButton(load("uid://0ilo4a8dvk77"))

        button1.focus_neighbor_left  = button3.get_path()
        button1.focus_neighbor_right = button2.get_path()
        button2.focus_neighbor_left  = button1.get_path()
        button2.focus_neighbor_right = button3.get_path()
        button3.focus_neighbor_left  = button2.get_path()
        button3.focus_neighbor_right = button1.get_path()

        button1.focus_neighbor_top = %Buttons.get_child(-1).get_path()
        button2.focus_neighbor_top = %Buttons.get_child(-1).get_path()
        button3.focus_neighbor_top = %Buttons.get_child(-1).get_path()
        
        if Saver.savegame.data.has("Level"):
            button1.levelInfo("Linea")
            button2.levelInfo("Circulus")
            button3.levelInfo("Quadratum")
            
    super.appear()

func appeared():
    
    if lastFocused:
        lastFocused.grab_focus()
    else:    
        levelButtons.get_child(1).grab_focus()
    super.appeared()
    
func vanish():
    
    lastFocused = Utils.focusedChild(self)
    super.vanish()

func addLevelButton(scene):
    
    var button : LevelButton = LEVEL_BUTTON.instantiate()
    levelButtons.add_child(button)
    button.setScene(scene)
    button.setSize(LEVEL_SIZE)
    button.pressed.connect(levelChosen.bind(scene))
    
    button.viewport.scene.floor.visible = false
    
    var level = button.viewport.scene.get_child(-1)
    if level is Level:
        level.showBuildSlots()
        level.get_node("Base").updateDots()
    
    var camera = button.viewport.scene.camera
    camera.global_position = Vector3(0, 10, 0) + Vector3.BACK*10
    camera.look_at(Vector3.FORWARD*10)
    camera.far = 1000
    
    button.viewport.setEnvironment(get_node("/root/World/Environment"))
    
    return button

func levelChosen(level):
    
    playLevel.emit(level)
