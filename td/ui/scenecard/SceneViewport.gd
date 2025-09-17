class_name SceneViewport extends SubViewport

@onready var scene: CardScene = %Scene

func setBuilding(buildingName:String):

    var sceneRes = load("res://ui/cards/Card%s.tscn" % buildingName)
    if sceneRes:
        setScene(sceneRes)

func setScene(sceneRes:PackedScene):
    
    %Scene.add_child(sceneRes.instantiate())
