class_name SceneViewport extends SubViewport

func setBuilding(buildingName:String):

    var sceneRes = load("res://ui/cards/Card%s.tscn" % buildingName)
    if sceneRes:
        setScene(sceneRes)

func setScene(scene:PackedScene):
    
    var node = scene.instantiate()
    %Scene.add_child(node)
