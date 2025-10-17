class_name Level 
extends Node3D

var inert       = true
var highscore   = 0
var trophyCount = [0, 0, 0]
var cards : Cards

const ENEMY = preload("uid://cqn35mciqmm8s")

func _ready():
    
    #Log.log("Level._ready", name, "inert:", inert)
    
    cards = Cards.new()
    add_child(cards)
            
    set_process(false)
    
    if inert:
        process_mode = Node.PROCESS_MODE_DISABLED
        #Log.log("Level._ready load inert level", name)
        loadLevel(Saver.savegame.data)
    
func start():
    
    Log.log("Level.start", get_path())
    add_to_group("game")
    set_process(true)
    Post.subscribe(self)
    %Clock.start()
    
    var shield = firstPlacedBuildingOfType("Shield")
    if shield:
        Post.statChanged.emit("shieldHitPoints", shield.hitPoints)
    else:
        Post.statChanged.emit("shieldHitPoints", 0)
    
func showBuildSlots():

    %SlotRing1.visible = true
    %SlotRing2.visible = true
    %SlotRing3.visible = true
    %SlotRing4.visible = true
    %SlotRing5.visible = true
    %SlotRing6.visible = true
    
func applyCards():
    
    var rings = cards.cardLvl(Card.SlotRing)

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
    
    var es = Stats.numEnemiesSpawned
    highscore = maxi(es, highscore)
    #Log.log("levelEnd", name, es, highscore)
    var trophyLimit = Info.trophyLimitsForLevel(name)
    if es >= trophyLimit[2]: 
        trophyCount[2] += 1
    elif es >= trophyLimit[1]:
        trophyCount[1] += 1
    elif es >= trophyLimit[0]:
        trophyCount[0] += 1
    
    cards.battle.clear()

    resetLevel(Saver.savegame.data)
    Saver.save()

func gamePaused():
    
    set_physics_process(false)
    set_process(false)
    
func gameResumed():
    
    set_physics_process(true)
    set_process(true)
    
func resetLevel(data:Dictionary):

    assert(data != null and data is Dictionary)
    if not data.has("Level"): data.Level = {}
                
    if not data.Level.has(name):
        saveLevel(data)
    
    var ld = data.Level[name]
    ld.highscore      = highscore
    ld.trophyCount    = trophyCount
    ld.lastScore      = Stats.numEnemiesSpawned
    ld.enemiesSpawned = 0
    ld.balance        = 0
    ld.baseHitPoints  = 3
    ld.erase("gameTime")
    ld.erase("clock")
    ld.erase("buildings")
    ld.erase("enemies")
    ld.erase("spawners")
    ld.player = get_node("/root/World/Player").save()
    ld.cards  = cards.save()
    #Log.log("resetLevel", name, data.Level[name])
    Post.levelSaved.emit(name) # to update main menu level cards

func saveLevel(data:Dictionary):
    
    if not data.has("Level"): data.Level = {}
    
    var ld = {}
    
    ld.highscore      = highscore
    ld.enemiesSpawned = Stats.numEnemiesSpawned
    ld.lastScore      = Stats.numEnemiesSpawned
    ld.balance        = Wallet.balance
    ld.clock          = %Clock.save()
    ld.gameTime       = Info.gameTime
    ld.baseHitPoints  = %Base.hitPoints
    ld.trophyCount    = trophyCount

    ld.player = get_node("/root/World/Player").save()
    ld.cards  = cards.save()

    ld.buildings = []
    get_tree().call_group("building", "saveBuilding", ld.buildings)
    
    ld.enemies = []
    for enemy in %Enemies.get_children():
        if enemy.spawned:
            ld.enemies.append(enemy.save())
    
    ld.spawners = []
    for spawner in Utils.childrenWithClass(%Spawners, "Spawner"):
        ld.spawners.append(spawner.save())

    data.Level[name] = ld
    #Log.log("levelSaved", name)
    Post.levelSaved.emit(name)

func loadLevel(data:Dictionary):
    
    if not data.has("Level"): return
    #Log.log("loadLevel", name, "inert", inert)
    if not data.Level.has(name): return
    
    var ld = data.Level[name]
    #Log.log("loadLevel", name, "inert", inert, ld)
    
    if ld.has("highscore"):
        highscore = ld.highscore
        
    if ld.has("enemiesSpawned"):
        Stats.setNumEnemiesSpawned(ld.enemiesSpawned)
        
    if ld.has("player") and not inert: 
        get_node("/root/World/Player").load(ld.player)   
        
    if ld.has("cards"):
        cards.load(ld.cards)
    
    if ld.has("balance"):
        Wallet.setBalance(ld.balance) 
        
    if ld.has("baseHitPoints"):
        %Base.setHitPoints(ld.baseHitPoints)

    if ld.has("clock"):
        %Clock.load(ld.clock)
        
    if ld.has("gameTime"):
        Info.gameTime = ld.gameTime
        
    if ld.has("trophyCount"):
        trophyCount = ld.trophyCount
    
    if ld.has("buildings"):
                
        for building in ld.buildings:
            var bld = load(building.res).instantiate()
            bld.inert = inert
            #Log.log("load building", building.type)
            if building.type == "Shield":
                add_child(bld)
                bld.global_position = Vector3.ZERO
                #Log.log("SHIELD LOADED", isAnyBuildingPlaced("Shield"))
            else:
                var slot = slotForPos(building.position)
                assert(slot)
                slot.add_child(bld)
                if not bld.global_position.is_zero_approx():
                    bld.look_at(Vector3.ZERO)
                    
    if ld.has("enemies"):
        
        Utils.freeChildren(%Enemies)
        
        for dict in ld.enemies:
            var enemy = ENEMY.instantiate()
            %Enemies.add_child(enemy)
            enemy.load(dict)
            
        get_node("MultiMesh")._process(0)
        
    if ld.has("spawners"):
        var spawners = Utils.childrenWithClass(%Spawners, "Spawner")
        for index in range(spawners.size()):
            var spawner = spawners[index]
            spawner.load(ld.spawners[index])

func slots():
    
    return Utils.filterTree(self, func(n:Node): return n is Slot)

func visibleSlots():
    
    return Utils.filterTree(self, func(n:Node): return n is Slot and n.visible and n.get_parent().visible)

func slotForPos(pos):
    
    return Utils.closestNode(slots(), pos)

func visibleSlotForPos(pos):
    
    return Utils.closestNode(visibleSlots(), pos)
    
func allPlacedBuildings():
    
    return Utils.childrenWithClass(self, "Building")
    
func allPlacedBuildingsOfType(type):
    
    return allPlacedBuildings().filter(func(b): return b.type == type)
    
func isAnyBuildingPlaced(type):
    
    return allPlacedBuildingsOfType(type).size() > 0

func firstPlacedBuildingOfType(type):  
    
    var buildings = allPlacedBuildingsOfType(type)
    if buildings.size():
        return buildings[0]
    return null
    
