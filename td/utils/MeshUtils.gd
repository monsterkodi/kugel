extends Node

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
