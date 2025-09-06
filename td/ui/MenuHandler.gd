class_name MenuHandler
extends CanvasLayer

const APPEAR_TIME     = 1.0
const VANISH_TIME     = 1.0
const SLIDE_IN_TIME   = 1.0
const SLIDE_OUT_TIME  = 1.0

const MENU_EASE  = Tween.EASE_IN_OUT
const MENU_TRANS = Tween.TRANS_SINE

var activeMenu : Control

func _ready():
    
    Post.subscribe(self)
    
func _unhandled_input(event: InputEvent):
    
    if event.is_action_pressed("ui_cancel"):
        if get_tree().paused:
            get_viewport().set_input_as_handled()
            get_node("/root/World").togglePause.call_deferred()
            return
                
func hideAllMenus():
    
    for child in get_children():
        child.visible = false

func vanishActive():
    
    if activeMenu:
        vanish(activeMenu, "top")

func showCardChooser(cards:Array):
    
    %CardChooser.setCards(cards)
    appear(%CardChooser)
    
func appear(menu:Control, from="bottom"):
    
    if activeMenu and activeMenu != menu:
        vanish(activeMenu, from, false)
    
    Post.menuSound.emit("appear")
        
    activeMenu = menu
    
    menu.show()
        
    Post.menuAppear.emit(menu)
        
    var tween = create_tween()
    tween.set_ease(MENU_EASE)
    tween.set_trans(MENU_TRANS)

    match from: 
        "bottom":
            menu.anchor_top    = 1
            menu.anchor_bottom = 2
            tween.tween_property(menu, "anchor_top", 0, APPEAR_TIME)
            tween.parallel().tween_property(menu, "anchor_bottom", 1, APPEAR_TIME)

        "right":
            menu.anchor_left   = 1
            menu.anchor_right  = 2
            tween.tween_property(menu, "anchor_left", 0, APPEAR_TIME)
            tween.parallel().tween_property(menu, "anchor_right", 1, APPEAR_TIME)

        "left":
            menu.anchor_left   = -1
            menu.anchor_right  = 0
            tween.tween_property(menu, "anchor_left", 0, APPEAR_TIME)
            tween.parallel().tween_property(menu, "anchor_right", 1, APPEAR_TIME)
    
    return tween

func vanish(menu, from="bottom", sound=true):
    
    if menu == activeMenu:
        activeMenu = null
    
    Post.menuVanish.emit(menu)
    if sound: Post.menuSound.emit("vanish")

    var tween = create_tween()
    tween.set_ease(MENU_EASE)
    tween.set_trans(MENU_TRANS)
    
    match from: 
    
        "bottom":
            tween.tween_property(menu, "anchor_top", -1, VANISH_TIME)
            tween.parallel().tween_property(menu, "anchor_bottom", 0, VANISH_TIME)

        "top":
            tween.tween_property(menu, "anchor_top", 1, VANISH_TIME)
            tween.parallel().tween_property(menu, "anchor_bottom", 2, VANISH_TIME)
            
        "right":
            tween.tween_property(menu, "anchor_left", -1, VANISH_TIME)
            tween.parallel().tween_property(menu, "anchor_right", 0, VANISH_TIME)            

        "left":
            tween.tween_property(menu, "anchor_left", 1, VANISH_TIME)
            tween.parallel().tween_property(menu, "anchor_right", 2, VANISH_TIME)            

    tween.tween_callback(menu.hide)
    return tween

func slideIn(menu:Control):

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
