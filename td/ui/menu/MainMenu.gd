class_name MainMenu
extends Menu

signal playLevel

@onready var levelButtons: HBoxContainer = %LevelButtons
const SCENE_VIEWPORT = preload("uid://bfs4v0hjfo8pg")

func onQuit():      Post.quitGame.emit()
func onSettings():  Post.settings.emit(self)
func onNewGame():   Post.newGame.emit()

const LEVEL_BUTTON = preload("uid://thwlxijax7nj")
const LEVEL_SIZE   = Vector2i(550,400)

func back(): 
    
    if %Quit.has_focus():
        Post.quitGame.emit()
    else:
        %Quit.grab_focus()
    
func vanished():
    
    Utils.freeChildren(levelButtons)    
    
func appear():

    Utils.freeChildren(levelButtons)
    
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
        levelInfo(button1, "Linea")
        levelInfo(button2, "Circulus")
        levelInfo(button3, "Quadratum")
            
    super.appear()

func levelInfo(button, levelName):
    
    if Saver.savegame.data.Level.has(levelName):
        
        var levelData = Saver.savegame.data.Level[levelName]
        
        trophyInfo(button, levelData)
        spawnedInfo(button, levelData)
        highscoreInfo(button, levelData)
        
func spawnedInfo(button, levelData):
    
    if not levelData.enemiesSpawned: return
    
    var spawned = Label.new()
    spawned.text = str(levelData.enemiesSpawned)
    spawned.vertical_alignment   = VERTICAL_ALIGNMENT_CENTER
    spawned.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT

    var topSide = MarginContainer.new()
    topSide.set_anchors_and_offsets_preset(Control.PRESET_TOP_WIDE, Control.PRESET_MODE_MINSIZE, 0)

    var panel = PanelContainer.new()
    panel.theme = preload("uid://by8tqmngtmh7o")
    panel.size_flags_horizontal = Control.SIZE_SHRINK_END
    panel.add_child(spawned)
    
    topSide.add_child(panel)
    button.viewport.add_child(topSide)
        
func highscoreInfo(button, levelData):
        
    var highscore = Label.new()
    highscore.text = str(levelData.highscore)
    highscore.vertical_alignment   = VERTICAL_ALIGNMENT_CENTER
    highscore.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER

    var hbox = HBoxContainer.new()
    hbox.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
    hbox.add_child(highscore)
    
    var panel = PanelContainer.new()
    panel.theme = preload("uid://cd7siqyqj6v1v")
    panel.set_anchors_and_offsets_preset(Control.PRESET_BOTTOM_WIDE, Control.PRESET_MODE_MINSIZE, 50)
    panel.add_child(hbox)
    
    button.add_child(panel)

func trophyInfo(button, levelData):
    
    if not levelData.has("trophyCount"): return
    var trophyCount = 0
    for i in range(3):
        trophyCount += levelData.trophyCount[i]
    if not trophyCount: return

    var vbox = VBoxContainer.new()
    vbox.size_flags_vertical = Control.SIZE_SHRINK_CENTER
    
    var leftSide = PanelContainer.new()
    leftSide.add_theme_stylebox_override("panel" ,StyleBoxEmpty.new())
    leftSide.set_anchors_and_offsets_preset(Control.PRESET_LEFT_WIDE, Control.PRESET_MODE_MINSIZE, 0)

    leftSide.theme = preload("uid://c6thyx2f0j183")

    var trophies = PanelContainer.new()
    trophies.set_anchors_and_offsets_preset(Control.PRESET_CENTER_LEFT, Control.PRESET_MODE_MINSIZE, 10)
    trophies.size_flags_vertical = Control.SIZE_SHRINK_CENTER
    trophies.add_child(vbox)
    
    leftSide.add_child(trophies)

    for metal in range(3):
        
        if levelData.trophyCount[metal]:

            var container : SubViewportContainer = SubViewportContainer.new()
            var trophy : SceneViewport = SCENE_VIEWPORT.instantiate()
            var resPath = "res://ui/cards/CardTrophy%s.tscn" % ["Bronce", "Silver", "Gold"][metal]
            
            trophy.setScene(load(resPath))
            trophy.size = Vector2i(50,50)
            container.add_child(trophy)
            
            
            var hb = HBoxContainer.new()
            hb.add_child(container)
            if levelData.trophyCount[metal] > 1:
                var label = Label.new()
                label.text = str(levelData.trophyCount[metal])
                hb.add_child(label)
            vbox.add_child(hb)

    button.add_child(leftSide)

func appeared():
        
    levelButtons.get_child(1).grab_focus()
    super.appeared()

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
    
    var camera = button.viewport.scene.camera
    camera.global_position = Vector3(0, 10, 0) + Vector3.BACK*10
    camera.look_at(Vector3.FORWARD*10)
    camera.far = 1000
    
    var environment : Environment = button.viewport.scene.environment.environment
    environment.fog_density = 0.0
    
    return button

func levelChosen(level):
    
    playLevel.emit(level)
