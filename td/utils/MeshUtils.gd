extends Node

func buildingClassNames():
    var classNames = ClassDB.get_class_list()
    for className in classNames:
        if className == &"Turret":
            Log.log("building?", className, ClassDB.get_parent_class(className))
            
    
