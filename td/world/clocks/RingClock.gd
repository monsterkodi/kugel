class_name RingClock
extends Clock

func startLevel():
    
    super.startLevel()
    
    %ClockRing.get_surface_override_material(0).set_shader_parameter("Revolution", 0.0)
        
func enemySpawned():
    
    %ClockRing.get_surface_override_material(0).set_shader_parameter("Revolution", minf(Stats.numEnemiesSpawned/800.0, 0.999))
    
func load(dict:Dictionary):
    
    super.load(dict)
    enemySpawned()
