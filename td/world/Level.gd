class_name Level extends Node3D

func gamePaused():
    
    Log.log('gamePaused')
    set_physics_process(false)
    set_process(false)
    
func gameResumed():
    
    Log.log('gameResumed')
    set_physics_process(true)
    set_process(true)
