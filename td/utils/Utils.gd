extends Node

func freeChildren(node:Node):
    
    while node.get_child_count():
        node.get_child(0).free()
    assert(node.get_child_count() == 0)

func resourcesInDir(dir:String) -> Array[Resource]:
    
    var resources:Array[Resource] = []
    for path in ResourceLoader.list_directory(dir):
        resources.append(load(dir + "/" + path))
    return resources
    
func allCards() -> Array[Card]:
    
    var cards:Array[Card] = []
    var cardResources = resourcesInDir("res://cards")
    for cardRes in cardResources:
        var card:Card = Card.new()
        card.setRes(cardRes)
        cards.append(card)
    return cards

func resourceNamesInDir(dir:String) -> PackedStringArray:

    var buildings = ResourceLoader.list_directory(dir)
    var names = PackedStringArray([])
    for b in buildings:
        name = b.get_file().get_basename()
        if name not in names:
            names.append(name)
    return names
    
func closestNode(nodes:Array, to:Vector3) -> Node3D:
    
    var minDist = INF
    var minNode = null
    for node in nodes:
        var dist = node.global_position.distance_squared_to(to)
        if dist < minDist:
            minNode = node
            minDist = dist
            
    return minNode
