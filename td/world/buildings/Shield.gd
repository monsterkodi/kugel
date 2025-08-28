class_name Shield extends Node3D

var inert = false
var hitPoints:int

func _ready():
    
    setHitPoints(3)

func onHit():
    
    setHitPoints(hitPoints - 1)
    Post.shieldDamaged.emit(self)
    
func setHitPoints(hp):
    
    hitPoints = maxi(0, hp)
    if hitPoints == 0:
        onShieldDown()
    Post.statChanged.emit("shieldHitPoints", hitPoints)

func onShieldDown():
    queue_free()

func _on_body_entered(body: Node3D):

    if body.is_in_group("enemy"):
        if body.alive():
            onHit()
            body.queue_free()
