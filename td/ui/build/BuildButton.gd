class_name BuildButton extends Control

const SCENE_SIZE = Vector2i(150,125) #100,76

signal pressed
signal focused

func buttonPressed(): pressed.emit(self)
func buttonFocused(): focused.emit(self)

@onready var scene: SceneViewport = %Scene

func setBuilding(building:String):
    
    name = building
    scene.setBuilding(building)
    setSize(SCENE_SIZE)

func setSize(sceneSize:Vector2i):
    
    scene.size = sceneSize
