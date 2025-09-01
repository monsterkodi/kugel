class_name CardButton
extends Button

@onready var scene: BuildingViewport = %Scene

@export var card:Card

func _ready():

    if card: setCard(card)
    
func setCard(c:Card):
    
    card = c
    text = card.name
    if card.scene:
        %Scene.setScene(card.scene)
        
func setWidth(width:int):
    
    scene.size.x = width

func setHeight(height:int):
    
    scene.size.y = height
    
func setSize(sceneSize:Vector2i):
    
    scene.size = sceneSize
