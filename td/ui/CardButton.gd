class_name CardButton
extends Button

@onready var scene: BuildingViewport = %Scene

@export var card:Card

func _ready():

    if card: setCard(card)
    
func setCard(c:Card):
    
    card = c
    add_child(card)
    text = card.res.name
    if card.res.scene:
        %Scene.setScene(card.res.scene)
        
    #if card.res.type == CardRes.CardType.PERMANENT:
        #setColor(Color(0.5, 0, 0))
        
#func setColor(color:Color):
    
    #Log.log("get_constant_type_list", theme.get_constant_type_list())
    #Log.log("get_constant_list", theme.get_constant_list())
    
    #var sb = get_theme_stylebox("normal", "Button")
    #Log.log("CardButton.setColor", sb)
    
    #Log.log("get_color_type_list", theme.get_color_type_list())
    #Log.log("get_stylebox_type_list", theme.get_stylebox_type_list())
    #Log.log("get_type_list()", theme.get_type_list())
    #for type in theme.get_type_list():
        #Log.log("type", type)
        #for sb in theme.get_stylebox_list(type):
            #Log.log("sb", sb, theme.get_theme_item(Theme.DataType.DATA_TYPE_STYLEBOX, sb, type))
        
func setWidth(width:int):
    
    scene.size.x = width
    %Circle.diameter = width/20.0

func setHeight(height:int):
    
    scene.size.y = height
    
func setSize(sceneSize:Vector2i):
    
    scene.size = sceneSize
