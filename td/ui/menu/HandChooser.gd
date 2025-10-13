class_name HandChooser
extends Menu

const CARD_BUTTON = preload("uid://cj3gelhoeb5ps")
const HAND_SIZE = Vector2i(300,200)
const DECK_SIZE = Vector2i(225,160)

func _on_visibility_changed():
    
    set_process_input(visible)
    
    if visible:

        updateHand()
        updateDeck()
    else:            
        Utils.freeChildren(%Hand)
        Utils.freeChildren(%Deck)
        
func updateHand():
    
    Utils.freeChildren(%Hand)
    var cards = get_node("/root/World").currentLevel.cards
    %Hand.custom_minimum_size.x = cards.battleCardSlots() * 300 + (cards.battleCardSlots() - 1) * 50
    for card in cards.hand.get_children():
        addHandButton(card)
                
func updateDeck():
    
    Utils.freeChildren(%Deck)
    var cards = get_node("/root/World").currentLevel.cards
    for card in cards.deck.sortedCards():
        addDeckButton(card)

func addHandButton(card):
    
    var button = CARD_BUTTON.instantiate()
    button.pressed.connect(buttonPressed.bind(button))
    %Hand.add_child(button)
    button.setCard(card)
    button.setSize(HAND_SIZE)
    return button
        
func addDeckButton(card):
    
    var button = CARD_BUTTON.instantiate()
    button.pressed.connect(buttonPressed.bind(button))
    %Deck.add_child(button)
    button.setCard(card)
    button.setSize(DECK_SIZE)
    return button       

func getDeckButton(cardName):
    
    for button in %Deck.get_children():
        if button.card.res.name == cardName:
            return button
    return null

func appeared():
    
    %Battle.grab_focus()            
    super.appeared()

func buttonPressed(button):
    
    if button.get_parent() == %Hand:
        moveHandCardToDeck(button)
    else:
        moveDeckCardToHand(button)

func moveHandCardToDeck(button):
    
    assert(button)
    
    var cards = get_node("/root/World").currentLevel.cards
    
    if cards.deck.cardLvl(button.card.res.name) >= 1:
        
        var deckButton = getDeckButton(button.card.res.name)
        assert(deckButton)
        deckButton.card.lvl += 1
        deckButton.setDots(deckButton.card.lvl)
        deckButton.grab_focus()
        
        cards.hand.delCard(button.card)
        %Hand.remove_child(button)
        button.queue_free()
    else:
        cards.deck.addCard(button.card)
        Utils.setParent(button, %Deck)
        button.setSize(DECK_SIZE)
        button.grab_focus()
    
func moveDeckCardToHand(button):
    
    var cards = get_node("/root/World").currentLevel.cards
    
    if cards.hand.get_child_count() == cards.battleCardSlots():
        moveHandCardToDeck(%Hand.get_child(0))
        
    if button.card.lvl > 1:
        button.card.lvl -= 1
        button.setDots(button.card.lvl)
        var newCard = Card.withName(button.card.res.name)
        cards.hand.addCard(newCard)
        addHandButton(newCard)
    else:
        cards.hand.addCard(button.card)
        Utils.setParent(button, %Hand)
        button.setSize(HAND_SIZE)
        button.grab_focus()
        
func back(): onBattle()

func onBattle():
    
    %MenuHandler.vanish(self, "top").tween_callback(func():Post.handChosen.emit())

func onCards():
    
    %MenuHandler.appear(%PermViewer, "right")
