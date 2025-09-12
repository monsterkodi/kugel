class_name PermViewer
extends Menu

const CARD_BUTTON = preload("uid://cj3gelhoeb5ps")
const DECK_SIZE = Vector2i(225,160)

var pauseOnBack = false

func _on_visibility_changed():
    
    if visible:

        Utils.freeChildren(%Deck)
        for card in %Player.perm.sortedCards():
            var button = CARD_BUTTON.instantiate()
            button.pressed.connect(buttonPressed.bind(button))
            %Deck.add_child(button)
            button.setCard(card)
            button.setSize(DECK_SIZE)
    else:            
        Utils.freeChildren(%Deck)
        
func appeared():
    
    %Back.grab_focus()
    super.appeared()

func buttonPressed(button):
    
    button.grab_focus()
    
func back():
    
    if pauseOnBack:
        %MenuHandler.appear(%PauseMenu, "left")
        pauseOnBack = false
    else:
        %MenuHandler.appear(%HandChooser, "left")
