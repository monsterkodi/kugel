class_name HandChooser
extends PanelContainer

const CARD_BUTTON = preload("uid://cj3gelhoeb5ps")
const HAND_SIZE = Vector2i(300,200)
const DECK_SIZE = Vector2i(225,160)

func _ready():
    
    set_process_input(false)

func _on_visibility_changed():
    
    set_process_input(visible)
    
    if visible:
                
        Utils.freeChildren(%Hand)
        for card in %Player.hand.cards:
            var button = CARD_BUTTON.instantiate()
            button.card = card
            button.pressed.connect(buttonPressed.bind(button))
            %Hand.add_child(button)
            button.setSize(HAND_SIZE)

        Utils.freeChildren(%Deck)
        for card in %Player.deck.cards:
            var button = CARD_BUTTON.instantiate()
            button.card = card
            button.pressed.connect(buttonPressed.bind(button))
            if card.res.type == CardRes.CardType.PERMANENT:
                button.get_node("Circle").visible = true
            %Deck.add_child(button)
            button.setSize(DECK_SIZE)
        
        %Done.grab_focus()            
    else:
        if is_inside_tree():
            %MenuHandler.appear(%Hud, true)
        Utils.freeChildren(%Hand)
        Utils.freeChildren(%Deck)

func buttonPressed(button):
    
    if button.get_parent() == %Hand:
        handButtonPressed(button)
    else:
        deckButtonPressed(button)

func moveHandCardToDeck(index:int):
    
    var button = %Hand.get_child(index)
    %Player.deck.addCard(button.card)
    %Player.hand.delCard(button.card)
    %Hand.remove_child(button)
    %Deck.add_child(button)
    button.setSize(DECK_SIZE)
    
func moveDeckCardToHand(index:int):
    
    var button = %Deck.get_child(index)
    if %Player.hand.cards.size() == Info.maxHandCards():
        moveHandCardToDeck(%Player.hand.cards.size()-1)
        
    %Player.hand.addCard(button.card)
    %Player.deck.delCard(button.card)
    %Deck.remove_child(button)
    %Hand.add_child(button)
    button.setSize(HAND_SIZE)

func deckButtonPressed(button):
    
    moveDeckCardToHand(%Deck.get_children().find(button))
    button.grab_focus()
    
func handButtonPressed(button):
    
    moveHandCardToDeck(%Hand.get_children().find(button))
    button.grab_focus()

func vanish():
    
    %MenuHandler.vanish(self).tween_callback(func():Post.handChosen.emit())

func _input(event: InputEvent):
    
    if event.is_action_pressed("ui_cancel"):
        accept_event()
        vanish()
        
func _on_done_button_pressed():
    
    vanish()
    
    
