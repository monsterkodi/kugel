extends Node3D

func _process(delta:float):
    
    var enemies = get_tree().get_nodes_in_group("enemy")
    var num = enemies.size()
    var emm:MultiMeshInstance3D = $Enemy
    emm.multimesh.instance_count = num
    for i in range(num):
        emm.multimesh.set_instance_transform(i, enemies[i].global_transform)
        emm.multimesh.set_instance_color(i, enemies[i].getColor())

    var slots = get_tree().get_nodes_in_group("slot")
    num = slots.size()  
    emm = $Slot 
    emm.multimesh.instance_count = num 
    for i in range(num):
        var trans = slots[i].global_transform
        trans = trans.translated(Vector3(0,0.01,0))
        emm.multimesh.set_instance_transform(i, trans)
 
