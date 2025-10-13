class_name Splash
extends Level

const SHIELD = preload("uid://busmvxaat6dqv")
const LASER  = preload("uid://dfa3dn75qvqpn")
const SNIPER = preload("uid://wjb8cyv4jvd8")

func _ready():
    
    super._ready()
    
    cards.perm.addCard(Card.withName(Card.ShieldLayer, 5))
    cards.perm.addCard(Card.withName(Card.SniperSpeed, 5))
    cards.perm.addCard(Card.withName(Card.LaserSpeed,  5))
    cards.perm.addCard(Card.withName(Card.LaserPower,  2))
    
    var shield = SHIELD.instantiate()
    shield.inert = false
    add_child(shield)
    
    shield.setHitPoints(cards.maxShieldHitPoints())
    shield.gameResume()
    
    for slot in %SlotRing1.get_children():
        slot.add_child(SNIPER.instantiate())

    for slot in %SlotRing2.get_children():
        slot.add_child(LASER.instantiate())
        
    for spawner in Utils.childrenWithClass(self, "Spawner"):
        spawner.get_node("Ident").visible = false
        spawner.velocity_initial = 1.0
        spawner.velocity         = 1.0
        
        spawner.mass_increment     = 0.33
        spawner.velocity_increment = 0.04
