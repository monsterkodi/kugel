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
        global_position = Vector3.ZERO + Vector3.BACK
    
    #if %BattleCards.countCards(Card.Shield):
        #%BattleCards.useCard(Card.Shield)
        #if not Info.isAnyBuildingPlaced("Shield"):
            #addShield()
    #else: 
        #delShield()
        
func loadVehicle(vehicle_name:String):
    
    if vehicle: vehicle.queue_free()
    vehicleName = vehicle_name
    var res = "res://vehicles/{0}.tscn".format([vehicleName])
    vehicle = load(res).instantiate()
    if vehicle_name == "Pill":
        get_parent_node_3d().add_child(vehicle)
        vehicle.transform = transform
        vehicle.player = self
    else:
        add_child(vehicle)
            
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
            
func addShield():
    
    Log.log("addShield")
    var shield = SHIELD.instantiate()
    shield.inert = false
    get_parent_node_3d().add_child(shield)
    shield.global_position = Vector3.ZERO

func delShield():
    
    Log.log("delShield")
    if Info.isAnyBuildingPlaced("Shield"):
        Post.statChanged.emit("shieldHitPoints", 0)
        get_node("/root/World/Shield").free()

func _unhandled_input(_event: InputEvent):
    
    if Input.is_action_just_pressed("alt_up", true):
        get_viewport().set_input_as_handled()
        position.y = 0
        match vehicleName:
            "Pill": loadVehicle("Heli")
            "Heli": loadVehicle("Pill")
            #"Car":  loadVehicle("Heli")
