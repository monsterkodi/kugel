class_name BattleCards
extends PanelContainer

const CARD_BUTTON = preload("uid://cj3gelhoeb5ps")
const CARD_SIZE   = Vector2i(100,76)

func _ready():
    
    Post.subscribe(self)

func levelStart():  updateButtons()
    
func updateButtons():
    
    Utils.freeChildren(%Cards)
    for card in %Player.battle.get_children():
        #if card.res.name == Card.Shield: continue
        Log.log(card.res.name, card.lvl)
        addCardButton(card)
        
    visible = true
    
func cardChosen(card):
    
    #Log.log("cardChosen", card.res.name)
    if card.isBattleCard():
        addCardButton(card)

func addCardButton(card:Card):
    
    assert(card)
    var button = CARD_BUTTON.instantiate()
    button.card = card
    %Cards.add_child(button)
    button.text = ""
    button.setSize(CARD_SIZE)
    
func countCards(cardName:String) -> int:
    
    var num = 0
    for button in %Cards.get_children():
        if button.card and button.card.res.name == cardName:
            num += 1
    return num
    
func useCard(cardName:String):
    
    for button in %Cards.get_children():
        if button.card and button.card.res.name == cardName:
            %Cards.remove_child(button)
            button.free()
            break
    %Player.battle.delCard(%Player.battle.getCard(cardName))
    
func levelEnd():
    
    visible = false
    Utils.freeChildren(%Cards)
    
