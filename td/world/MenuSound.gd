extends Node

var active = true

func _ready():
    
    Post.subscribe(self)

func menuAppear(menu:Control):
    
    active = false

func menuDidAppear(menu:Control):
    
    active = true
    var items = Utils.childrenWithClasses(menu, ["Button", "HSlider"])
    for item in items:
        if not item.focus_entered.is_connected(menuSound):
            item.focus_entered.connect(menuSound.bind("focus", 1.0 +(item.get_index() / 4.0)))
            
        #if item is Button:
            #if not item.pressed.is_connected(menuSound):
                #item.pressed.connect(menuSound.bind("button"))
        
func menuVanish(menu:Control):
    
    var items = Utils.childrenWithClasses(menu, ["Button", "HSlider"])
    for item in items:
        if item.focus_entered.is_connected(menuSound):
            item.focus_entered.disconnect(menuSound)

func menuSound(action:String, pitch = 1.0):
    
    if not active: return
    var sound:AudioStreamPlayer2D = find_child(action)
    if sound: 
        sound.pitch_scale = pitch
        sound.play()
    else: Log.log("can't find sound for action", action)
