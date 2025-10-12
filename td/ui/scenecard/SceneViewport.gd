class_name SceneViewport 
extends SubViewport

@onready var scene: CardScene = %Scene

func _ready():
    
    use_debanding = true
    screen_space_aa = ScreenSpaceAA.SCREEN_SPACE_AA_FXAA

func setBuilding(buildingName:String):

    var sceneRes = load("res://ui/cards/Card%s.tscn" % buildingName)
    if sceneRes:
        setScene(sceneRes)

func setEnvironment(environment):
    
    scene.environment.free()
    scene.add_child(environment.duplicate())

func setScene(sceneRes:PackedScene):
 
    delLevel()   
    %Scene.add_child(sceneRes.instantiate())
    
func setLevel(levelRes:PackedScene, inert=true):
    
    delLevel()    
    
    var level = levelRes.instantiate()
    level.inert = inert

    %Scene.add_child(level)
    return level

func delLevel():
    
    Utils.freeChildWithClass(%Scene, "Level")
