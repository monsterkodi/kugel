class_name LevelButton
extends Button

const SCENE_VIEWPORT = preload("uid://bfs4v0hjfo8pg")

@onready var viewport: SceneViewport = %Viewport

func setScene(scene:PackedScene):
    
    text = scene.resource_path.get_file().get_basename()
    viewport.setScene(scene)
    
func setColor(color:Color):
    
    var sb = get_theme_stylebox("normal", "Button").duplicate()
    sb.bg_color = color * 0.5
    add_theme_stylebox_override("normal", sb)
    add_theme_color_override("font_color", color)
    
func setSize(sceneSize:Vector2i):
    
    viewport.size = sceneSize

func levelInfo(levelName):
    
    if Saver.savegame.data.Level.has(levelName):
        
        var levelData = Saver.savegame.data.Level[levelName]
        
        trophyInfo(levelData)
        balanceInfo(levelData)
        spawnedInfo(levelData)
        highscoreInfo(levelData)
        
func spawnedInfo(levelData):
    
    Utils.freeChildWithName(viewport, "spawned")

    if not levelData.enemiesSpawned: return
    
    var spawned = Label.new()
    spawned.text = str(levelData.enemiesSpawned)
    spawned.vertical_alignment   = VERTICAL_ALIGNMENT_CENTER
    spawned.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT

    var topSide = MarginContainer.new()
    topSide.name = "spawned"
    topSide.set_anchors_and_offsets_preset(Control.PRESET_TOP_WIDE, Control.PRESET_MODE_MINSIZE, 0)

    var panel = PanelContainer.new()
    panel.theme = preload("uid://by8tqmngtmh7o")
    panel.size_flags_horizontal = Control.SIZE_SHRINK_END
    panel.add_child(spawned)
        
    topSide.add_child(panel)
    viewport.add_child(topSide)

func balanceInfo(levelData):
    
    Utils.freeChildWithName(viewport, "balance")

    if not levelData.enemiesSpawned: return
    
    var balance = Label.new()
    balance.text = str(levelData.balance)
    balance.vertical_alignment   = VERTICAL_ALIGNMENT_CENTER
    balance.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT

    var topSide = MarginContainer.new()
    topSide.name = "balance"
    topSide.set_anchors_and_offsets_preset(Control.PRESET_TOP_WIDE, Control.PRESET_MODE_MINSIZE, 0)

    var panel = PanelContainer.new()
    panel.theme = preload("uid://dstnyurutnm4c")
    panel.size_flags_horizontal = Control.SIZE_SHRINK_BEGIN
    panel.add_child(balance)
        
    topSide.add_child(panel)
    viewport.add_child(topSide)
            
func highscoreInfo(levelData):
       
    Utils.freeChildWithName(self, "highscore") 

    if not levelData.highscore: return

    var highscore = Label.new()
    highscore.text = str(levelData.highscore)
    highscore.vertical_alignment   = VERTICAL_ALIGNMENT_CENTER
    highscore.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER

    var hbox = HBoxContainer.new()
    hbox.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
    hbox.add_child(highscore)
    
    var panel = PanelContainer.new()
    panel.theme = preload("uid://cd7siqyqj6v1v")
    panel.name = "highscore"
    panel.set_anchors_and_offsets_preset(Control.PRESET_BOTTOM_WIDE, Control.PRESET_MODE_MINSIZE, 50)
    panel.add_child(hbox)
    
    add_child(panel)

func trophyInfo(levelData):
    
    Utils.freeChildWithName(self, "trophies") 

    if not levelData.has("trophyCount"): return
    var trophyCount = 0
    for i in range(3):
        trophyCount += levelData.trophyCount[i]
    if not trophyCount: return

    var vbox = VBoxContainer.new()
    vbox.size_flags_vertical = Control.SIZE_SHRINK_CENTER
    
    var leftSide = PanelContainer.new()
    leftSide.name = "trophies"
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

    add_child(leftSide)
