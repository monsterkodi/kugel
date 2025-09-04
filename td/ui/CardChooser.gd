class_name CardChooser
extends PanelContainer

@onready var cardButtons: HBoxContainer = %CardButtons

const CARD_BUTTON = preload("uid://cj3gelhoeb5ps")
const CARD_SIZE   = Vector2i(375,375)

func _ready():
    
    set_process_input(false)
    
func setCards(cards:Array):
    
    assert(cards.size() == 3)
    
    Utils.freeChildren(cardButtons)
        
    for card in cards:
        assert(card is Card)
        addCardButton(card)
            
    assert(cardButtons.get_child_count() == 3)
    cardButtons.get_child(1).grab_focus()

func addCardButton(card:Card):
    
    var button = CARD_BUTTON.instantiate()
    button.card = card
    cardButtons.add_child(button)
    button.setSize(CARD_SIZE)
    button.pressed.connect(cardChosen.bind(card))

func cardChosen(card):
    
    Post.cardChosen.emit(card)
    %MenuHandler.vanish(self)

func _on_visibility_changed():
    
    set_process_input(visible)
    if visible:
        %MenuHandler.slideOut(%Hud)

func _input(event: InputEvent):
    
    if event.is_action_pressed("ui_cancel"):
        for button in cardButtons.get_children():
            if button.has_focus():
                cardChosen(button.card)
                break
        accept_event()
        %MenuHandler.vanish(self)
