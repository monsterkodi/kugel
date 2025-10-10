class_name Player
extends Node3D

const SHIELD = preload("uid://busmvxaat6dqv")

var vehicleName = "Pill"
var vehicle     : Node3D
var nextCardIn  : int
var cardLevel   : int

var deck   : Deck
var hand   : Deck
var perm   : Deck
var battle : Deck

func _ready():
    
    #Log.log("ready player one", get_parent_node_3d())
    deck   = Deck.new()
    hand   = Deck.new()
    perm   = Deck.new()
    battle = Deck.new()
    
    hand.stacked   = false
    battle.stacked = false
    
    add_child(deck)
    add_child(hand)
    add_child(perm)
    add_child(battle)
    
    Post.subscribe(self)
    
func levelReset():
    
    Log.log("Player.levelReset")
    battle.clear()
    
func startLevel():
    
    cardLevel  = 0
    nextCardIn = 5

    deck  .clear()
    hand  .clear()
    perm  .clear()
    battle.clear()
    
    perm.addCard(Card.withName(Card.BattleCard))
    
    if not vehicle:
        loadVehicle("Pill")
    
func loadVehicle(vehicle_name:String):
    
    var oldTrans : Transform3D
    var corpses = []
    if vehicle: 
        oldTrans = vehicle.global_transform
        corpses = vehicle.collector.corpses
        vehicle.queue_free()
    else:
        oldTrans = Transform3D.IDENTITY.translated(Vector3.BACK)
    vehicleName = vehicle_name
    var res = "res://vehicles/{0}.tscn".format([vehicleName])
    vehicle = load(res).instantiate()

    var f = func(): vehicle.collector.corpses.append_array(corpses) 
    vehicle.ready.connect(f)
    get_parent_node_3d().add_child(vehicle)
    vehicle.player = self
    vehicle.global_transform = oldTrans
    
func save() -> Dictionary:
    
    var dict = {}
    
    dict.transform         = global_transform
    dict.vehicle           = vehicleName
    dict.vehicle_transform = vehicle.transform
    dict.vehicle_velocity  = vehicle.linear_velocity
    
    dict.hand              = hand.toDict()
    dict.deck              = deck.toDict()
    dict.perm              = perm.toDict()
    dict.battle            = battle.toDict()
    dict.nextCardIn        = nextCardIn
    dict.cardLevel         = cardLevel
    
    return dict
    
func load(dict:Dictionary):
    
    loadVehicle(dict.vehicle)
    global_transform         = dict.transform
    vehicle.transform        = dict.vehicle_transform
    vehicle.linear_velocity  = dict.vehicle_velocity
        
    cardLevel  = maxi(dict.cardLevel, 0)
    nextCardIn = clampi(dict.nextCardIn, 1, Info.nextCardAtLevel(cardLevel))
    
    hand.fromDict(dict.hand)
    deck.fromDict(dict.deck)
    perm.fromDict(dict.perm)
    battle.fromDict(dict.battle)
        
func currentLevel(): return get_node("/root/World").currentLevel
            
func _unhandled_input(_event: InputEvent):
    
    if Input.is_action_just_pressed("flying", true):
        get_viewport().set_input_as_handled()
        position.y = 0
        match vehicleName:
            "Pill": loadVehicle("Heli")
            "Heli": loadVehicle("Pill")
