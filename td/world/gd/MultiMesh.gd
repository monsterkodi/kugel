extends Node3D

var dict = {"dot": [], "slot": [], "enemy": [], "bullet": []}

func add(typ:String, node:Node3D):

    #Log.log("add", get_parent().get_script().get_global_name(), typ)
    dict[typ].append(node)
    
func del(typ:String, node:Node3D):
    
    #Log.log("del", get_parent().get_script().get_global_name(), typ)
    dict[typ].erase(node)

func _process(delta:float):
    
    #if get_parent().inert:
        #Log.log("mm", get_parent().name, get_parent().inert)
        
    var mmi:MultiMeshInstance3D
    var num:int
    
    var dots = dict.dot
    num = dots.size()  
    mmi = $Dot 
    mmi.multimesh.instance_count = num 
    for i in range(num):
        var trans = dots[i].global_transform
        var sc = dots[i].getRadius()
        trans = trans.scaled_local(Vector3(sc,sc,sc))
        mmi.multimesh.set_instance_transform(i, trans)
        mmi.multimesh.set_instance_color(i, dots[i].getColor())
    
    var slots = dict.slot
    num = slots.size()  
    mmi = $Slot 
    mmi.multimesh.instance_count = num 
    for i in range(num):
        var trans = slots[i].global_transform
        trans = trans.translated(Vector3(0,0.01,0))
        mmi.multimesh.set_instance_transform(i, trans)
 
    var enemies = dict.enemy
    num = enemies.size()
    mmi = $Enemy
    mmi.multimesh.instance_count = num
    for i in range(num):
        mmi.multimesh.set_instance_transform(i, enemies[i].global_transform)
        mmi.multimesh.set_instance_color(i, enemies[i].getColor())

    #var bullets = get_tree().get_nodes_in_group("bullet")
    var bullets = dict.bullet
    num = bullets.size()  
    mmi = $Bullet 
    mmi.multimesh.instance_count = num 
    for i in range(num):
        mmi.multimesh.set_instance_transform(i, bullets[i].global_transform)
        mmi.multimesh.set_instance_color(i, bullets[i].getColor())
