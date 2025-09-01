extends Node

var buildingNames:PackedStringArray
var enemySpeed:float

func _ready():
    
    enemySpeed = 1
    buildingNames = Utils.resourceNamesInDir("res://world/buildings")
    #Log.log("Info.buildingNames", buildingNames)
    #Log.log("Info.buildingNamesSortedByPrice", buildingNamesSortedByPrice())

func priceForBuilding(buildingName):
    
    match buildingName:
        "Shield":  return 40
        "Laser":   return 20
        "Turret":  return 10
        "Bouncer": return 5
        "Pole":    return 2
        _:         return 0

func buildingNamesSortedByPrice() -> Array:
    
    var names = Array(buildingNames)
    names.sort_custom(func(a,b): return priceForBuilding(a) < priceForBuilding(b))
    return names
    
func allPlacedBuildings():
    
    return get_tree().get_nodes_in_group("building")
    
func allPlacedBuildingsOfType(type):
    
    return allPlacedBuildings().filter(func(b): return b.type == type)
    
func isAnyBuildingPlaced(type):
    
    return allPlacedBuildingsOfType(type).size() > 0
    
func slotForPos(pos):
    
    var slots = get_tree().get_nodes_in_group("slot")
    return Utils.closestNode(slots, pos)

    
    
