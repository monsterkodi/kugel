class_name CardChooser
extends Menu

@onready var cardButtons: HBoxContainer = %CardButtons

const CARD_BUTTON = preload("uid://cj3gelhoeb5ps")
const CARD_SIZE   = Vector2i(375,325)
    
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
    button.setCard(card)
    button.setSize(CARD_SIZE)
    button.pressed.connect(cardChosen.bind(card))

func cardChosen(card):
    Log.log("cardChosen", card)
    Post.cardChosen.emit(card)

func _input(event: InputEvent):
    
    if event.is_action_pressed("ui_cancel"):
        accept_event()
        return
    
    #if event.is_action_pressed("ui_cancel"):
        ##Log.log("CARD CHOOSE CANCEL")
        #for button in cardButtons.get_children():
            #if button.has_focus():
                #cardChosen(button.card)
                #break
                #
    super._input(event)
