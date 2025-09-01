class_name HandChooser
extends PanelContainer

const CARD_BUTTON = preload("uid://cj3gelhoeb5ps")
const HAND_SIZE = Vector2i(300,200)
const DECK_SIZE = Vector2i(225,160)

func _ready():
    
    set_process_input(false)

func _on_visibility_changed():
    
    if visible:
        
        %MenuHandler.vanish(%Hud)
        
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
            %Deck.add_child(button)
            button.setSize(DECK_SIZE)
            
        #%Deck.get_child(%Deck.get_child_count()-1).grab_focus()
        %Done.grab_focus()
        set_process_input(true)
            
    else:
        Utils.freeChildren(%Hand)
        Utils.freeChildren(%Deck)
        set_process_input(false)

func buttonPressed(button):
    
    if button.get_parent() == %Hand:
        handButtonPressed(button)
    else:
        deckButtonPressed(button)

func deckButtonPressed(button):
    
    Log.log("deck", button, button.card, button.card.name)
    %Player.hand.addCard(button.card)
    %Player.deck.delCard(button.card)
    %Deck.remove_child(button)
    %Hand.add_child(button)
    button.setSize(HAND_SIZE)
    button.grab_focus()
    
func handButtonPressed(button):
    
    Log.log("hand", button, button.card, button.card.name)
    %Player.deck.addCard(button.card)
    %Player.hand.delCard(button.card)
    %Hand.remove_child(button)
    %Deck.add_child(button)
    button.setSize(DECK_SIZE)
    button.grab_focus()

func vanish():
    
    %MenuHandler.vanish(self).tween_callback(func():Post.handChosen.emit())

func _input(event: InputEvent):
    
    if event.is_action_pressed("ui_cancel"):
        accept_event()
        vanish()
        
func _on_done_button_pressed():
    
    vanish()
    
    
