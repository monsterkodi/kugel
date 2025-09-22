class_name MainMenu
extends Menu

signal playLevel

@onready var levelButtons: HBoxContainer = %LevelButtons

func onQuit():      Post.quitGame.emit()
func onSettings():  Post.settings.emit(self)
func onNewGame():   Post.newGame.emit()

const LEVEL_BUTTON = preload("uid://thwlxijax7nj")
const LEVEL_SIZE   = Vector2i(500,400)

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
    camera.global_position = Vector3(0, 120, 0)
    camera.look_at(Vector3.FORWARD)
    camera.far = 1000
    
    var environment : Environment = button.viewport.scene.environment.environment
    environment.fog_density = 0
    
    return button

func levelChosen(level):
    
    playLevel.emit(level)
