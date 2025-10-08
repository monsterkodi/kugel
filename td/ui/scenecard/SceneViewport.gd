class_name SceneViewport extends SubViewport

@onready var scene: CardScene = %Scene

func setBuilding(buildingName:String):

    var sceneRes = load("res://ui/cards/Card%s.tscn" % buildingName)
    if sceneRes:
        setScene(sceneRes)

func setScene(sceneRes:PackedScene):
    
    if %Scene.get_child(-1) is Level:
        Log.log("SceneViewport remove last level")
        %Scene.get_child(-1).free()
    %Scene.add_child(sceneRes.instantiate())
