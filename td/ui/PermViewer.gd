class_name PermViewer
extends Menu

const CARD_BUTTON = preload("uid://cj3gelhoeb5ps")
const DECK_SIZE = Vector2i(225,160)

var resumeOnBack = false

func _on_visibility_changed():
    
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
    else:            
        Utils.freeChildren(%Deck)
        
func appeared():
    
    %Back.grab_focus()
    super.appeared()

func buttonPressed(button):
    
    button.grab_focus()
    
func back():
    
    if resumeOnBack:
        Post.resumeGame.emit()
        resumeOnBack = false
    else:
        %MenuHandler.appear(%HandChooser, "left")
