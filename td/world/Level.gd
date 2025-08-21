class_name Level extends Node3D

#func _ready():

    #Log.log("ready", self)
    
#func _process(delta):

    #Log.log("process", self, delta)
    
func gamePaused():
    
    Log.log('gamePaused')
    set_physics_process(false)
    set_process(false)
    
func gameResumed():
    
    Log.log('gameResumed')
    set_physics_process(true)
    set_process(true)
