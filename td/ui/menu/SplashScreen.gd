class_name SplashScreen
extends Menu

@onready var viewport: SceneViewport = %SceneViewport
@onready var viewportContainer: SubViewportContainer = %SubViewportContainer

const SPLASH = preload("uid://qtgb1as1bp7l")

var level

func _ready():
    
    viewport.scene.floor.visible = false
    viewport.scene.camera.global_position.y = 15
    viewport.scene.camera.global_position.z = 25
    viewport.scene.camera.look_at(Vector3.FORWARD * 10)
    viewport.setEnvironment(get_node("/root/World/Environment"))
    
    loadLevel()

func loadLevel():

    level = viewport.setLevel(SPLASH, false)
    level.set_process_input(false)
    level.get_node("Clock").startLevel()
    level.start()

func back():
    
    backMenu = %MainMenu
    level.process_mode = Node.PROCESS_MODE_DISABLED
    get_tree().paused = true
    super.back()
    
func vanished():
    
    level.free()
    
func onResize():

    if not viewport: return
    viewportContainer.size = get_window().size

func _input(event: InputEvent):
    
    if event is InputEventJoypadButton or event is InputEventKey or event is InputEventMouseButton:
        back()
