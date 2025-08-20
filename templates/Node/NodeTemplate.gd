
class_name _CLASS_ extends _BASE_

func _ready():
    
    #await get_parent().ready
    
    Log.log("ready", self)
    
func _process(delta):

    Log.log("process", self, delta)
    
