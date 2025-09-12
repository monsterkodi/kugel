extends Node

func nameDict(arr:Array) -> Dictionary:
    
    var dict = {}
    for item in arr:
        dict[item.name] = item
    return dict    

func methodDict(node:Node): return nameDict(node.get_method_list())
func signalDict(node:Node): return nameDict(node.get_signal_list())

func setParent(node:Node, newParent:Node):
    
    if node.get_parent():
        node.get_parent().remove_child(node)
    newParent.add_child(node)
    return node
    
func filterTree(node:Node, predicate:Callable):
    
    var filtered = []
    for child in node.get_children():
        if predicate.call(child): 
            filtered.append(child)
        filtered.append_array(filterTree(child, predicate))
    return filtered
    
func childrenWithClass(node:Node, className:String):
    
    return filterTree(node, func(n:Node): 
        return n.get_class() == className or ClassDB.is_parent_class(n.get_class(), className))

func childrenWithClasses(node:Node, classNames:Array[String]):
    
    var filtered = []
    for className in classNames:
        filtered.append_array(childrenWithClass(node, className))
    return filtered

func freeChildren(node:Node):
    
    while node.get_child_count():
        node.get_child(0).free()
    assert(node.get_child_count() == 0)

func resourcesInDir(dir:String) -> Array[Resource]:
    
    var resources:Array[Resource] = []
    for path in ResourceLoader.list_directory(dir):
        if path[-1] == "/":
            resources.append_array(resourcesInDir(dir + "/" + path))
        else:
            var res = load(dir + "/" + path)
            if res: resources.append(res)
    return resources
    
#func allCardRes() -> Array[CardRes]:
    #
    #var ary:Array[CardRes] 
    #ary.assign(resourcesInDir("res://cards"))
    #return ary
    #
#func cardResWithName(cardName:String) -> CardRes:
    #
    #var cards = allCardRes()
    #var index = cards.find_custom(func(c): return c.name == cardName)
    #if index >= 0:
        #return cards[index]
    #return null
#
#func newCardWithName(cardName:String) -> Card:
    #
    #var cardRes = cardResWithName(cardName)
    #if cardRes: return Card.new(cardRes)
    #return null

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
