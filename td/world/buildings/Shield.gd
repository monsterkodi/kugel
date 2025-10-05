class_name Shield extends Building

var hitPoints:int

func _ready():

    name = "Shield"
    
    setHitPoints(Info.maxShieldHitPoints())
    #Log.log("Shield._ready", inert)
    %ShieldBody.position = Vector3.ZERO
    global_position = Vector3.ZERO
    set_physics_process(false)
    %ShieldBody.freeze = true
    super._ready()
    
func gameResume():
    
    if not inert:
        %ShieldBody.freeze = false
        set_physics_process(true)
        
func onHit():
    
    setHitPoints(hitPoints - 1)
    Post.shieldDamaged.emit(self)
    Post.gameSound.emit(self, "shieldHit")
    
func addLayer():
    
    while %Halos.get_child_count() > 1:
        %Halos.get_child(-1).free()
    setHitPoints(hitPoints+1)
    
func setHitPoints(hp):
    
    hitPoints = maxi(0, hp)
    
    if not inert:
        Post.statChanged.emit("shieldHitPoints", hitPoints)
        
    if hitPoints == 0:
        onShieldDown()
    
    while %Halos.get_child_count() < hitPoints:
        var clone = %Halos.get_child(0).duplicate()
        var s = clone.scale.x + ((3.0/hitPoints)*%Halos.get_child_count())
        clone.scale = Vector3(s,s,s)
        %Halos.add_child(clone)
    while %Halos.get_child_count() > hitPoints:
        %Halos.get_child(-1).free()

func onShieldDown():
    
    set_physics_process(false)
    get_parent_node_3d().remove_child.call_deferred(self)
    Post.gameSound.emit(self, "shieldDown")
    queue_free()

func _on_body_entered(body: Node3D):

    if body.is_in_group("enemy") and hitPoints:
        if body.alive():
            onHit()
            body.die()
