class_name MenuHandler
extends CanvasLayer

const APPEAR_TIME     = 1.0
const VANISH_TIME     = 0.5
const SLIDE_IN_TIME   = 1.0
const SLIDE_OUT_TIME  = 0.5

var activeMenu : Control

func _ready():
    
    Post.subscribe(self)
    
func _unhandled_input(event: InputEvent):
    
    if event.is_action_pressed("ui_cancel"):
        #Log.log("InputHandler.ui_cancel")
        if get_tree().paused:
            get_viewport().set_input_as_handled()
            get_node("/root/World").togglePause.call_deferred()
            return
                
func hideAllMenus():
    
    for child in get_children():
        child.visible = false

func vanishActive():
    
    if activeMenu:
        vanish(activeMenu)

func showCardChooser(cards:Array):
    
    %CardChooser.setCards(cards)
    appear(%CardChooser)
    
func appear(menu:Control):
    
    if activeMenu and activeMenu != menu:
        vanish(activeMenu, false)
    
    Post.menuSound.emit("appear")
        
    activeMenu = menu
    
    menu.show()
    
    menu.anchor_top    = 1
    menu.anchor_bottom = 2
    
    Post.menuAppear.emit(menu)
        
    var tween = create_tween()
    tween.set_ease(Tween.EASE_OUT)
    tween.set_trans(Tween.TRANS_QUINT)
    tween.tween_property(menu, "anchor_top", 0, APPEAR_TIME)
    tween.parallel().tween_property(menu, "anchor_bottom", 1, APPEAR_TIME)
    return tween

func vanish(menu, sound=true):
    
    if menu == activeMenu:
        activeMenu = null
    
    Post.menuVanish.emit(menu)
    if sound: Post.menuSound.emit("vanish")
        
    menu.anchor_top    = 0
    menu.anchor_bottom = 1

    var tween = create_tween()
    tween.tween_property(menu, "anchor_top", -1, VANISH_TIME)
    tween.parallel().tween_property(menu, "anchor_bottom", 0, VANISH_TIME)
    tween.tween_callback(menu.hide)
    #tween.tween_callback(func(): menu.anchor_top = 0; menu.anchor_bottom = 1)
    return tween

func slideIn(menu:Control):
    #Log.log("slideIn", menu, menu.size.y)
    menu.show()
    
    menu.anchor_top    = 0 - menu.size.y/1080.0
    menu.anchor_bottom = 1 - menu.size.y/1080.0
        
    var tween = create_tween()
    tween.set_ease(Tween.EASE_OUT)
    tween.set_trans(Tween.TRANS_QUINT)
    tween.tween_property(menu, "anchor_top", 0, SLIDE_IN_TIME)
    tween.parallel().tween_property(menu, "anchor_bottom", 1, SLIDE_IN_TIME)
    return tween
    
func slideOut(menu:Control):
    #Log.log("slideOut", menu, menu.size.y)
    menu.anchor_top    = 0
    menu.anchor_bottom = 1

    var tween = create_tween()
    tween.tween_property(menu, "anchor_top", 0 - menu.size.y/1080.0, SLIDE_OUT_TIME)
    tween.parallel().tween_property(menu, "anchor_bottom", 1 - menu.size.y/1080.0, SLIDE_OUT_TIME)
    tween.tween_callback(menu.hide)
    return tween    
