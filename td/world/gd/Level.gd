class_name Level 
extends Node3D

var inert     = true
var highscore = 0

const ENEMY = preload("uid://cqn35mciqmm8s")

func _ready():
    
    Log.log("Level._ready", name, "inert:", inert)
            
    set_process(false)
    
    if inert:
        Log.log("Level._ready", name, "inert:", inert, "load inert?")
        loadLevel(Saver.savegame.data)
    
func start():
    
    Log.log("Level.start")
    add_to_group("game")
    set_process(true)
    Post.subscribe(self)
    %Clock.start()
    
func applyCards():
    
    var rings = Info.cardLvl(Card.SlotRing)
    Log.log("rings", rings)
    %SlotRing1.visible = true
    %SlotRing2.visible = (rings >= 1)
    %SlotRing3.visible = (rings >= 2)
    %SlotRing4.visible = (rings >= 3)
    %SlotRing5.visible = (rings >= 4)
    %SlotRing6.visible = (rings >= 5)
    
func statChanged(statName, value):
    
    match statName:
        "numEnemiesSpawned":
            highscore = maxi(value, highscore)
    
func levelEnd():
    
    highscore = maxi(Stats.numEnemiesSpawned, highscore)
    Log.log("levelEnd", Stats.numEnemiesSpawned, highscore)
    resetLevel(Saver.savegame.data)

func gamePaused():
    
    set_physics_process(false)
    set_process(false)
    
func gameResumed():
    
    set_physics_process(true)
    set_process(true)
    
func resetLevel(data:Dictionary):

    Log.log("resetLevel", data)
    if data.has("Level") and data.Level.has(name): 
        data.Level[name].highscore = highscore
        data.Level[name].enemiesSpawned = 0
        data.Level[name].walletBalance  = 0
        data.Level[name].baseHitPoints  = 3
        data.Level[name].erase("gameTime")
        data.Level[name].erase("clock")
        data.Level[name].erase("buildings")
        data.Level[name].erase("enemies")
        data.Level[name].erase("spawners")
        Log.log("resetLevel", name, data.Level[name])

func clearLevel(data:Dictionary):
    
    Log.log("clearLevel", data)
    if data.has("Level"): 
        data.Level[name] = {}
        data.Level[name].highscore = highscore
        Log.log("clearLevel", name, data.Level[name])

func saveLevel(data:Dictionary):
    
    if not data.has("Level"): data.Level = {}
    
    data.Level[name] = {}
    data.Level[name].highscore = highscore
    data.Level[name].enemiesSpawned = Stats.numEnemiesSpawned
    data.Level[name].walletBalance  = Wallet.balance
    data.Level[name].clock          = %Clock.save()
    data.Level[name].gameTime       = Info.gameTime
    data.Level[name].baseHitPoints  = %Base.hitPoints

    data.Level[name].player = get_node("/root/World/Player").save()

    data.Level[name].buildings = []
    get_tree().call_group("building", "saveBuilding", data.Level[name].buildings)
    
    data.Level[name].enemies = []
    for enemy in %Enemies.get_children():
        if enemy.spawned:
            data.Level[name].enemies.append(enemy.save())
    
    data.Level[name].spawners = []
    for spawner in Utils.childrenWithClass(%Spawners, "Spawner"):
        data.Level[name].spawners.append(spawner.save())

    Log.log("saveLevel", name, data.Level[name])

func loadLevel(data:Dictionary):
    
    if not data.has("Level"): return
    if not data.Level.has(name): return
    
    Log.log("loadLevel", name, "inert", inert, data.Level[name])
    
    if data.Level[name].has("highscore"):
        highscore = data.Level[name].highscore
        
    if data.Level[name].has("enemiesSpawned"):
        Stats.setNumEnemiesSpawned(data.Level[name].enemiesSpawned)
        
    if data.Level[name].has("player"): 
        get_node("/root/World/Player").load(data.Level[name].player)   
    
    if data.Level[name].has("walletBalance"):
        Wallet.setBalance(data.Level[name].walletBalance) 
        
    if data.Level[name].has("baseHitPoints"):
        %Base.setHitPoints(data.Level[name].baseHitPoints)

    if data.Level[name].has("clock"):
        %Clock.load(data.Level[name].clock)
        
    if data.Level[name].has("gameTime"):
        Info.gameTime = data.Level[name].gameTime
    
    if data.Level[name].has("buildings"):
                
        for building in data.Level[name].buildings:
            var bld = load(building.res).instantiate()
            bld.inert = inert
            #Log.log("load building", building.type)
            if building.type == "Shield":
                add_child(bld)
                bld.global_position = Vector3.ZERO
                Log.log("SHIELD LOADED", Info.isAnyBuildingPlaced("Shield"))
            else:
                var slot = slotForPos(building.position)
                assert(slot)
                slot.add_child(bld)
                if not bld.global_position.is_zero_approx():
                    bld.look_at(Vector3.ZERO)
                    
    if data.Level[name].has("enemies"):
        
        Utils.freeChildren(%Enemies)
        
        for dict in data.Level[name].enemies:
            var enemy = ENEMY.instantiate()
            %Enemies.add_child(enemy)
            enemy.load(dict)
            
        get_node("MultiMesh")._process(0)
        
    if data.Level[name].has("spawners"):
        var spawners = Utils.childrenWithClass(%Spawners, "Spawner")
        for index in range(spawners.size()):
            var spawner = spawners[index]
            spawner.load(data.Level[name].spawners[index])

func slotForPos(pos):
    
    var slots = Utils.filterTree(self, func(n:Node): return n is Slot)
    return Utils.closestNode(slots, pos)

func visibleSlotForPos(pos):
    
    var slots = Utils.filterTree(self, func(n:Node): return n is Slot and n.visible and n.get_parent().visible)
    return Utils.closestNode(slots, pos)
    
