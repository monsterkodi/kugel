class_name SplashScreen
extends Menu

@onready var viewport: SceneViewport = %SceneViewport
const LINEA = preload("uid://btl7cihfnbl6u")
@onready var viewportContainer: SubViewportContainer = %SubViewportContainer

func _ready():
    
    viewport.setScene(LINEA)
    #super._ready()

func back():
    
    backMenu = %MainMenu
    #backFrom = "top"
    super.back()
    
func onResize():

    if not viewport: return
    #if get_window().content_scale_mode == Window.CONTENT_SCALE_MODE_CANVAS_ITEMS:
    viewportContainer.size = get_window().size
    #else:
        #viewport.size = get_window().content_scale_size

func _input(event: InputEvent):
    
    if event is InputEventJoypadButton or event is InputEventKey or event is InputEventMouseButton:
        back()
