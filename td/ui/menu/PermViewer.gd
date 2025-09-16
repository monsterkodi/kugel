class_name PermViewer
extends Menu

const CARD_BUTTON = preload("uid://cj3gelhoeb5ps")
const DECK_SIZE = Vector2i(225,160)

var pauseOnBack = false

func _on_visibility_changed():
    
    if visible:
        update()
    else:            
        Utils.freeChildren(%Deck)

func update():
    
    Utils.freeChildren(%Deck)
    for card in %Player.perm.sortedCards():
        var button = CARD_BUTTON.instantiate()
        button.pressed.connect(buttonPressed.bind(button))
        %Deck.add_child(button)
        button.setCard(card)
        button.setSize(DECK_SIZE)
        
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

func _input(event: InputEvent):
    
    if event.is_action_pressed("alt_left"):
        accept_event()
        var focused = Utils.focusedChild(self)
        if focused is CardButton:
            var index = focused.get_index()
            Log.log("sell card", focused.card.res.name)
            Post.cardSold.emit(focused.card)
            update()
            if %Deck.get_child_count():
                %Deck.get_child(mini(%Deck.get_child_count()-1, index)).grab_focus()
            else:
                %Back.grab_focus()
        
    super._input(event)
