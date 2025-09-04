class_name BattleCards
extends PanelContainer

const CARD_BUTTON = preload("uid://cj3gelhoeb5ps")
const CARD_SIZE = Vector2i(100,66)

func _ready():
    
    Post.subscribe(self)

func levelStart():
    
    Utils.freeChildren(%Cards)
    for card in %Player.hand.get_children():
        var button = CARD_BUTTON.instantiate()
        button.card = card
        %Cards.add_child(button)
        button.setSize(CARD_SIZE)
        
    visible = true
    
func levelEnd():
    
    visible = false
    Utils.freeChildren(%Cards)
    
