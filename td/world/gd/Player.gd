class_name Player
extends Node3D

var vehicleName = "Pill"
var vehicle     : Node3D
var nextCardIn  : int
var cardLevel   : int

var deck : Deck
var hand : Deck
var perm : Deck

func _ready():
    
    add_to_group("save")
    
    #Log.log("ready player one", get_parent_node_3d())
    deck = Deck.new()
    hand = Deck.new()
    perm = Deck.new()
    
    add_child(deck)
    add_child(hand)
    add_child(perm)
    
    loadVehicle.call_deferred("Pill")
    
    Post.subscribe(self)

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
    
func _unhandled_input(_event: InputEvent):
    
    if Input.is_action_just_pressed("alt_up", true):
        get_viewport().set_input_as_handled()
        position.y = 0
        match vehicleName:
            "Pill": loadVehicle("Car")
            "Car":  loadVehicle("Heli")
            "Heli": loadVehicle("Pill")
        
func on_save(data:Dictionary):

    data.Player = {}
    data.Player.transform  = transform
    data.Player.vehicle    = vehicleName
    data.Player.hand       = hand.toDict()
    data.Player.deck       = deck.toDict()
    data.Player.perm       = perm.toDict()
    data.Player.nextCardIn = nextCardIn
    data.Player.cardLevel  = cardLevel
    
func on_load(data:Dictionary):
    
    nextCardIn = 5
    cardLevel  = 0
    
    if data.has("Player"):
    
        transform = data.Player.transform
        loadVehicle(data.Player.vehicle)
        
        if data.Player.has("cardLevel"):  cardLevel  = maxi(data.Player.cardLevel, 0)
        if data.Player.has("nextCardIn"): nextCardIn = clampi(data.Player.nextCardIn, 1, Info.CARD_LEVELS[cardLevel])
        
        if data.Player.has("hand"): hand.fromDict(data.Player.hand)
        if data.Player.has("deck"): deck.fromDict(data.Player.deck)
        if data.Player.has("perm"): perm.fromDict(data.Player.perm)

    Log.log("Player.load", cardLevel, nextCardIn)

const SHIELD = preload("uid://busmvxaat6dqv")
    
func addShield():
    
    var shield = SHIELD.instantiate()
    shield.inert = false
    get_parent_node_3d().add_child(shield)
    shield.global_position = Vector3.ZERO

func levelStart():
    
    for card in hand.get_children():
        match card.res.name:
            "Shield": addShield()
            _: Log.log("card", card.res.name)
