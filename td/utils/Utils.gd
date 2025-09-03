extends Node

func nameDict(arr:Array) -> Dictionary:
    
    var dict = {}
    for item in arr:
        dict[item.name] = item
    return dict    

func methodDict(node:Node): return nameDict(node.get_method_list())
func signalDict(node:Node): return nameDict(node.get_signal_list())

func freeChildren(node:Node):
    
    while node.get_child_count():
        node.get_child(0).free()
    assert(node.get_child_count() == 0)

func resourcesInDir(dir:String) -> Array[Resource]:
    
    var resources:Array[Resource] = []
    for path in ResourceLoader.list_directory(dir):
        if path[-1] == "/":
            resources.append_array(resourcesInDir(dir + path))
        else:
            var res = load(dir + "/" + path)
            if res: resources.append(res)
    return resources
    
func allCards() -> Array[Card]:
    
    var cards:Array[Card] = []
    var cardResources = resourcesInDir("res://cards")
    for cardRes in cardResources:
        var card:Card = Card.new()
        card.setRes(cardRes)
        cards.append(card)
    return cards
    
func cardWithName(cardName:String) -> Card:
    
    var cards = allCards()
    var index = cards.find_custom(func(c): return c.name == cardName)
    if index >= 0:
        return cards[index]
    return null

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
