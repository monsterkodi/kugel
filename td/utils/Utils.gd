extends Node

func rotateTowards(node:Node3D, targetDir:Vector3, rotAngle:float) -> float:
    
    var normal = node.basis.z.cross(targetDir)
    if normal.is_zero_approx(): return -666
    normal = normal.normalized()
    var dir   = -node.basis.z
    var angle = dir.signed_angle_to(targetDir, normal)
    dir = dir.rotated(normal, clampf(angle, -rotAngle, rotAngle))
    node.basis.z = -dir
    node.basis.x = dir.cross(Vector3.UP).normalized()
    node.basis.y = node.basis.z.cross(node.basis.x).normalized()
    return rad_to_deg(angle)

func timeStr(s:float) -> String:
    
    var hour = int(s/(3600.0))
    var min  = int(s/60.0) % 60
    return "%d:%02d:%02d" % [hour, min, int(s)%60]

func nameDict(arr:Array) -> Dictionary:
    
    var dict = {}
    for item in arr:
        dict[item.name] = item
    return dict    

func methodDict(node:Node): return nameDict(node.get_method_list())
func signalDict(node:Node): return nameDict(node.get_signal_list())

func trimFloat(f:float, decimals=1):
    
    var fmt = "%.{0}f".format([decimals])
    var str = fmt % f
    if str == "0.0": str = "0"
    if str.find(".") > 0:
        str = str.rstrip(".0")
    return str

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
    
func filterParents(node:Node, predicate:Callable):
    
    var filtered = []
    if node.get_parent():
        if predicate.call(node.get_parent()): 
            filtered.append(node.get_parent())
        filtered.append_array(filterParents(node.get_parent(), predicate))
    return filtered    
    
func parentsWithClass(node:Node, className:String):
    
    return filterParents(node, func(n:Node): return isClass(n, className))

func isScriptClass(script:Script, className:String):
    
    if script:
        if script.get_global_name() == className:
            return true
        return isScriptClass(script.get_base_script(), className)   
    return false
    
func isClass(node:Node, className:String):
    
    return node.get_class() == className or \
        ClassDB.is_parent_class(node.get_class(), className) or \
        isScriptClass(node.get_script(), className)

func firstParentWithClass(node:Node, className:String):
    
    var parent = node.get_parent()
    while parent:
        if isClass(parent, className):
            return parent
        parent = parent.get_parent()
    return null
    
func level(node:Node): return firstParentWithClass(node, "Level")
    
func childrenWithClass(node:Node, className:String):
    
    return filterTree(node, func(n:Node): return isClass(n, className))

func childrenWithClasses(node:Node, classNames:Array[String]):
    
    var filtered = []
    for className in classNames:
        filtered.append_array(childrenWithClass(node, className))
    return filtered
    
func focusedChild(node:Node):
    
    var focused = filterTree(node, func(n:Node): return n is Control and n.has_focus())
    if focused.size(): 
        return focused[0]
    return null

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

func wrapFocusVertical(node):
    
    node.get_child(0).focus_neighbor_top     = node.get_child(-1).get_path()
    node.get_child(-1).focus_neighbor_bottom = node.get_child(0).get_path()
