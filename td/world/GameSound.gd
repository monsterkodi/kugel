extends Node

func _ready():
    
    Post.subscribe(self)
    
func gameSound(source:Node3D, action:String):
    
    var sound:AudioStreamPlayer3D = find_child(action)
    if sound: 
        sound.global_position = source.global_position
        sound.play()
    else: Log.log("can't find sound for action", action)
