extends Node

func _ready():
    
    Post.subscribe(self)

func menuAppear(menu:Control):
    
    var items = Utils.childrenWithClasses(menu, ["Button", "HSlider"])
    for item in items:
        if not item.focus_entered.is_connected(menuSound):
            item.focus_entered.connect(menuSound.bind("focus"))
        
func menuVanish(menu:Control):
    
    var items = Utils.childrenWithClasses(menu, ["Button", "HSlider"])
    for item in items:
        if item.focus_entered.is_connected(menuSound):
            item.focus_entered.disconnect(menuSound)

func menuSound(action:String):
    
    var sound:AudioStreamPlayer2D = find_child(action)
    if sound: sound.play()
    else: Log.log("can't find sound for action", action)
