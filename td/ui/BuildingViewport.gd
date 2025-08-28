class_name BuildingViewport extends SubViewport

func setBuilding(buildingName:String):

    var building = load("res://world/buildings/%s.tscn" % buildingName).instantiate()
    
    var mesh = building.find_child("*Mesh*")
    var bb:AABB = mesh.get_aabb()
    %Camera.look_at(bb.get_center(), Vector3.UP)
    
    if ClassDB.class_get_property(building, "inert") != null:
        building.inert = true
        
    %Scene.add_child(building)
