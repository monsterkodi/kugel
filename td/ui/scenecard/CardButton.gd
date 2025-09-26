class_name CardButton
extends Button

@onready var sceneViewport: SceneViewport = %Scene
@onready var dots : HBoxContainer

@export var card:Card

const CIRCLE = preload("uid://c2q8strea6bfu")

func _ready():

    if has_node("Dots"):
        dots = %Dots
    if card: setCard(card)
    
func setScene(scene):
    
    sceneViewport.setScene(scene)
    
func setCardWithName(n:String):
    
    setCard(Card.withName(n))
        
func setCard(c:Card):
    
    card = c
    if card.get_parent() == null:
        add_child(card)
    text = card.res.name
    if card.res.scene:
        setScene(card.res.scene)
        
    if card.res.type == CardRes.CardType.PERMANENT:
        setColor(Color(0.3, 0.3, 1.0, 1.0))
    
    setDots(c.lvl)
        
func setDots(numDots):
    
    Utils.freeChildren(%Dots)
    
    if numDots > 1:
        #Log.log("numDots", numDots)
        for i in range(numDots):
            var dot = CIRCLE.instantiate()
            dot.diameter = sceneViewport.size.y/6.0
            dot.color = Color(0.3, 0.3, 1.0, 1.0)
            %Dots.add_child(dot)
        
func setColor(color:Color):
    
    var sb = get_theme_stylebox("normal", "Button").duplicate()
    sb.bg_color = color * 0.5
    add_theme_stylebox_override("normal", sb)
    add_theme_color_override("font_color", color)
    
func setSize(sceneSize:Vector2i):
    
    sceneViewport.size = sceneSize
    if dots:
        dots.offset_bottom = sceneViewport.size.y/18.0
