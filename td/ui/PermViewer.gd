class_name PermViewer
extends Menu

const CARD_BUTTON = preload("uid://cj3gelhoeb5ps")
const DECK_SIZE = Vector2i(225,160)

func _on_visibility_changed():
    
    #set_process_input(visible)
    
    if visible:

        Utils.freeChildren(%Deck)
        for card in %Player.perm.sortedCards():
            var button = CARD_BUTTON.instantiate()
            button.card = card
            button.pressed.connect(buttonPressed.bind(button))
            if card.res.type == CardRes.CardType.PERMANENT:
                button.get_node("Circle").visible = true
            %Deck.add_child(button)
            button.setSize(DECK_SIZE)
        #%Back.grab_focus()            
    else:            
        Utils.freeChildren(%Deck)
        
func appeared():
    
    %Back.grab_focus()
    super.appeared()

func buttonPressed(button):
    
    button.grab_focus()
    
func vanish():
    
    %MenuHandler.appear(%HandChooser, "left")

#func _input(event: InputEvent):
    #
    #if event.is_action_pressed("ui_cancel"):
        #accept_event()
        #vanish()
        
func _on_back_pressed():
    
    vanish()
