class_name CardButton
extends Button

@onready var scene: SceneViewport = %Scene

@export var card:Card

func _ready():

    if card: setCard(card)
    
func setCard(c:Card):
    
    card = c
    if card.get_parent() == null:
        add_child(card)
    text = card.res.name
    if card.res.scene:
        %Scene.setScene.call_deferred(card.res.scene)
        
    if card.res.type == CardRes.CardType.PERMANENT:
        setColor(Color(0.3, 0.3, 1.0, 1.0))
        
func setColor(color:Color):
    
    var sb = get_theme_stylebox("normal", "Button").duplicate()
    sb.bg_color = color * 0.5
    add_theme_stylebox_override("normal", sb)
    add_theme_color_override("font_color", color)
    
func setSize(sceneSize:Vector2i):
    
    scene.size = sceneSize
