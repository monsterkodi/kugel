class_name MenuHandler
extends CanvasLayer

func _ready():
    
    Post.cardChosen.connect(cardChosen)
    Post.handChosen.connect(handChosen)
    
func _unhandled_input(event: InputEvent):
    
    if event.is_action_pressed("ui_cancel"):
        Log.log("InputHandler.ui_cancel")
        if get_tree().paused:
            get_viewport().set_input_as_handled()
            get_node("/root/World").togglePause.call_deferred()
            return
                
func cardChosen(card:Card):
    
    if %Player.hand.cards.size() < Info.maxHandCards():
        %Player.hand.addCard(card)
    else:
        %Player.deck.addCard(card)
        
    appear(%HandChooser)

func handChosen():
    
    Post.startLevel.emit()
    
func hideAllMenus():
    
    for child in get_children():
        child.visible = false

func showCardChooser(cards:Array):
    
    %CardChooser.setCards(cards)
    appear(%CardChooser)
    
func appear(menu:Control, reverse=false):
    
    menu.show()
    if reverse:
        menu.anchor_top    = -1
        menu.anchor_bottom = 0
    else:
        menu.anchor_top    = 1
        menu.anchor_bottom = 2
        
    var tween = create_tween()
    tween.set_ease(Tween.EASE_OUT)
    tween.set_trans(Tween.TRANS_QUINT)
    tween.tween_property(menu, "anchor_top", 0, 2.0)
    tween.parallel().tween_property(menu, "anchor_bottom", 1, 3.0)
    return tween

func vanish(menu):
    
    menu.anchor_top    = 0
    menu.anchor_bottom = 1

    var tween = create_tween()
    tween.tween_property(menu, "anchor_top", -1, 0.5)
    tween.parallel().tween_property(menu, "anchor_bottom", 0, 0.5)
    tween.tween_callback(menu.hide)
    #tween.tween_callback(func(): menu.anchor_top = 0; menu.anchor_bottom = 1)
    return tween
