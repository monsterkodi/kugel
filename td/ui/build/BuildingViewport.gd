class_name BuildingViewport extends SubViewport

func setBuilding(buildingName:String):

    var building = load("res://world/buildings/%s.tscn" % buildingName).instantiate()
    
    var mesh = building.find_child("*Mesh*")
    var camera = %Scene.get_node("Camera")
    if mesh:
        var bb:AABB = mesh.get_aabb()
        camera.look_at(bb.get_center(), Vector3.UP)
    else:
        camera.look_at(Vector3.ZERO, Vector3.UP)
    
    building.inert = true
        
    %Scene.add_child(building)

func setScene(scene:PackedScene):
    
    var node = scene.instantiate()

    if node is Building:
        node.inert = true

    %Scene.add_child(node)
    
    #var mesh = node.find_child("*Mesh*")
    #if mesh:
        #var bb:AABB = mesh.get_aabb()
        #%Scene.get_node("Camera").look_at(bb.get_center(), Vector3.UP)
    
