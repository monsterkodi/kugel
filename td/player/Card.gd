class_name Card
extends Node

static var ShieldLayer  = "Shield Layer"
static var BattleCard   = "Battle Card"
static var SlotRing     = "Slot Ring"
static var Shield       = "Shield"
static var Bouncer      = "Bouncer"
static var Turret       = "Turret"
static var Laser        = "Laser"
static var Pole         = "Pole"
static var Sniper       = "Sniper"
static var SniperRange  = "Sniper Range"
static var SniperSpeed  = "Sniper Speed"
static var PillRange    = "Pill Range"
static var PillPower    = "Pill Power"
static var LaserRange   = "Laser Range"
static var LaserSpeed   = "Laser Speed"
static var LaserPower   = "Laser Power"
static var TurretRange  = "Turret Range"
static var TurretSpeed  = "Turret Speed"
static var TurretPower  = "Turret Power"
static var BouncerRange = "Bouncer Range"
static var BouncerSpeed = "Bouncer Speed"
static var BouncerPower = "Bouncer Power"

static var Unlock = {
    
    Card.SlotRing    : 50,
        
    Card.Laser       : 100,
    Card.LaserRange  : 100,
    Card.LaserSpeed  : 100,
    Card.LaserPower  : 100,
    
    Card.Shield      : 200,
    Card.ShieldLayer : 200,

    Card.Sniper      : 400,
    Card.SniperRange : 400,
    Card.SniperSpeed : 400,
}

static func allRes() -> Array[CardRes]:
    
    var ary:Array[CardRes] 
    ary.assign(Utils.resourcesInDir("res://cards"))
    return ary
    
static func resWithName(cardName:String) -> CardRes:
    
    var cards = allRes()
    var index = cards.find_custom(func(c): return c.name == cardName)
    if index >= 0:
        return cards[index]
    return null

static func withName(cardName:String) -> Card:
    
    var cardRes = resWithName(cardName)
    if cardRes: return Card.new(cardRes)
    return null

var res:CardRes

func _init(cardRes:CardRes):
    
    res = cardRes
    
func _to_string():   return res.name
    
func isBattleCard(): return res.type == CardRes.CardType.BATTLE
func isPermanent():  return res.type == CardRes.CardType.PERMANENT
func isOnce():       return res.type == CardRes.CardType.ONCE
