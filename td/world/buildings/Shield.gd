class_name Shield extends Building

var hitPoints:int

func _ready():

    name = "Shield"
    
    setHitPoints(Info.maxShieldHitPoints())
    
    super._ready()
    
func onHit():
    
    setHitPoints(hitPoints - 1)
    Post.shieldDamaged.emit(self)
    
func setHitPoints(hp):
    
    hitPoints = maxi(0, hp)
    if hitPoints == 0:
        onShieldDown()
    
    if not inert:
        Post.statChanged.emit("shieldHitPoints", hitPoints)
    
    while %Halos.get_child_count() < hitPoints:
        var clone = %Halos.get_child(0).duplicate()
        var s = clone.scale.x + ((3.0/hitPoints)*%Halos.get_child_count())
        clone.scale = Vector3(s,s,s)
        %Halos.add_child(clone)
    while %Halos.get_child_count() > hitPoints:
        %Halos.get_child(-1).free()

func onShieldDown():
    queue_free()

func _on_body_entered(body: Node3D):

    if body.is_in_group("enemy"):
        if body.alive():
            onHit()
            body.die()
