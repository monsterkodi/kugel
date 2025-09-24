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
static var TrophyBronce = "Bronce"
static var TrophySilver = "Silver"
static var TrophyGold   = "Gold"
static var Money        = "Money"

static var Unlock = {

    Card.BouncerRange : 30,
    Card.BouncerSpeed : 30,
    Card.BouncerPower : 30,
    
    Card.LaserRange   : 50,
    Card.LaserSpeed   : 50,
    Card.LaserPower   : 50,
    
    Card.SniperRange  : 110,
    Card.SniperSpeed  : 120,
    
    Card.ShieldLayer  : 150,
    
    Card.TrophyBronce : 500,
    Card.TrophySilver : 1000,
    Card.TrophyGold   : 2000,
}

static func calcMaxCardLevel():
    
    var maxLevel = 0
    for aRes in allRes():
        if aRes.isBattleCard() or aRes.isPermanent():
            maxLevel += aRes.maxLvl
    return maxLevel       

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

var res : CardRes
var lvl : int

func _init(cardRes:CardRes, l:int = 1):
    
    res = cardRes
    lvl = l
    
func _to_string():   return "[%s %d]" % [res.name, lvl]
    
func isBattleCard(): return res.isBattleCard() 
func isPermanent():  return res.isPermanent()  
func isTrophy():     return res.isTrophy()   
func isOnce():       return res.isOnce()      
