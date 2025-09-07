class_name CardProgress
extends PanelContainer

func _ready():
    
    Post.subscribe(self)
    
func levelStart():
    
    applyCards()

func enemySpawned(spawner:Spawner): applyCards()
    
func applyCards():
    
    var progress = 1.0 - float(%Player.nextCardIn-1) / float(Info.CARD_LEVELS[%Player.cardLevel])
    #Log.log("progress", progress, %Player.nextCardIn, Info.CARD_LEVELS[%Player.cardLevel])
    %Progress.custom_minimum_size.x = Info.CARD_LEVELS[%Player.cardLevel] * 2
    %Progress.set_value(progress*100)
    Log.log("progress", %Progress.value, progress, %Player.nextCardIn, Info.CARD_LEVELS[%Player.cardLevel])
