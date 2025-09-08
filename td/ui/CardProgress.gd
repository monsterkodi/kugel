class_name CardProgress
extends PanelContainer

func _ready():
    
    Post.subscribe(self)
    
func levelStart(): update()

func enemySpawned(spawner:Spawner): update()
    
func applyCards(): update()

func update():
    
    var progress = 1.0 - float(%Player.nextCardIn-1) / float(Info.nextCardAtLevel(%Player.cardLevel))
    %Progress.custom_minimum_size.x = Info.nextCardAtLevel(%Player.cardLevel) * 2
    %Progress.set_value(progress*100)
    Log.log("progress", %Progress.value, progress, %Player.nextCardIn, Info.nextCardAtLevel(%Player.cardLevel))
