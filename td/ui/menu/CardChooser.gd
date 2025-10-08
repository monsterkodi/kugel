class_name CardChooser
extends Menu

@onready var cardButtons: HBoxContainer = %CardButtons

const CARD_BUTTON = preload("uid://cj3gelhoeb5ps")
const CARD_SIZE   = Vector2i(375,325)
const DOT_SIZE    = 30
    
func setCards(cards:Array):
    
    assert(cards.size() == 3)
    
    Utils.freeChildren(cardButtons)
        
    for card in cards:
        assert(card is Card)
        addCardButton(card)
            
    assert(cardButtons.get_child_count() == 3)
    
func appeared():
    
    cardButtons.get_child(1).grab_focus()
    super.appeared()

func addCardButton(card:Card):
    
    var button = CARD_BUTTON.instantiate()
    cardButtons.add_child(button)
    button.setSize(CARD_SIZE, DOT_SIZE)
    button.setCard(card)
    button.pressed.connect(cardChosen.bind(card))

func cardChosen(card):
    
    Post.cardChosen.emit(card)

func _input(event: InputEvent):
    
    for action in ["pause", "build", "ui_cancel"]:
        if event.is_action_pressed(action):
            accept_event()
            return
    
    super._input(event)
