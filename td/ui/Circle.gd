extends Panel

@export var diameter:float = 16.0:
    set(v): custom_minimum_size = Vector2(v, v)

@export var color:Color = Color(1,1,1):
    set(v): modulate = v
    
func _ready():
    
    Log.log("constant_type_list", theme.get_constant_type_list())
