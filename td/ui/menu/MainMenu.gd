class_name MainMenu
extends Menu

signal loadLevel

@onready var levelButtons: HBoxContainer = %LevelButtons

const LEVEL_BUTTON = preload("uid://thwlxijax7nj")
const LEVEL_SIZE   = Vector2i(500,450)

func _ready(): pass
    
func appear():

    Utils.freeChildren(levelButtons)
    
    addLevelButton(load("uid://btl7cihfnbl6u"))
    addLevelButton(load("uid://wo631fluqa0p"))
    
    super.appear()

func appeared():
        
    levelButtons.get_child(0).grab_focus()
    super.appeared()

func addLevelButton(scene):
    
    var button = LEVEL_BUTTON.instantiate()
    levelButtons.add_child(button)
    button.setScene(scene)
    button.setSize(LEVEL_SIZE)
    button.pressed.connect(levelChosen.bind(scene))
    
    button.viewport.scene.floor.visible = false
    
    var camera = button.viewport.scene.camera
    camera.global_position = Vector3(0, 50, 50)
    camera.look_at(Vector3.ZERO)
    camera.far = 1000
    
    var environment : Environment = button.viewport.scene.environment.environment
    environment.fog_density = 0

func levelChosen(level):
    
    loadLevel.emit(level)
