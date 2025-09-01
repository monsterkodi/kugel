class_name CardChooser
extends PanelContainer

@onready var cardButtons: HBoxContainer = %CardButtons

const CARD_BUTTON = preload("uid://cj3gelhoeb5ps")
const CARD_SIZE = Vector2i(375,375)

func setCards(cards:Array):
    
    assert(cards.size() == 3)
    
    while cardButtons.get_child_count():
        cardButtons.remove_child(cardButtons.get_child(0))
        
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
    
    #Log.log("card chosen", card.name)
    Post.cardChosen.emit(card)
    %MenuHandler.vanish(self)
