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

var res:CardRes

func _init(cardRes:CardRes):
    
    res = cardRes
    
func _to_string():   return res.name
    
func isBattleCard(): return res.type == CardRes.CardType.BATTLE
func isPermanent():  return res.type == CardRes.CardType.PERMANENT
func isOnce():       return res.type == CardRes.CardType.ONCE
