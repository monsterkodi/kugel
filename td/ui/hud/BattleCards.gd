class_name BattleCards
extends PanelContainer

const CARD_BUTTON = preload("uid://cj3gelhoeb5ps")
const CARD_SIZE   = Vector2i(100,76)

func _ready():
    
    Post.subscribe(self)

func levelStart():
    
    Utils.freeChildren(%Cards)
    for card in %Player.hand.get_children():
        if card.res.name == Card.Shield: continue
        addCardButton(card)
        
    visible = true
    
func cardChosen(card):
    
    #Log.log("cardChosen", card.res.name)
    if card.isBattleCard():
        addCardButton(card)

func addCardButton(card:Card):
    
    var button = CARD_BUTTON.instantiate()
    button.card = card
    %Cards.add_child(button)
    button.text = ""
    button.setSize(CARD_SIZE)
    
func countBattleCards(cardName:String) -> int:
    
    var num = 0
    for button in %Cards.get_children():
        if button.card.res.name == cardName:
            num += 1
    return num
    
func useBattleCard(cardName:String):
    
    for button in %Cards.get_children():
        if button.card.res.name == cardName:
            button.free()
            return
    
func levelEnd():
    
    visible = false
    Utils.freeChildren(%Cards)
    
