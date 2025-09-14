class_name MenuHandler
extends CanvasLayer

static var TIMESCALE       = 0.4
static var APPEAR_TIME     = 1     * TIMESCALE
static var VANISH_TIME     = 1     * TIMESCALE
static var SLIDE_IN_TIME   = 0.5   * TIMESCALE
static var SLIDE_OUT_TIME  = 1     * TIMESCALE

const SLIDE_RIGHT     = 1.0/8.0

const MENU_EASE  = Tween.EASE_IN_OUT
const MENU_TRANS = Tween.TRANS_SINE

var activeMenu  : Control
var vanishMenu  : Control
var appearTween : Tween
var vanishTween : Tween

func _ready():
    
    Post.subscribe(self)
    
func _unhandled_input(event: InputEvent):
    
    if event.is_action_pressed("ui_cancel"):
        if get_tree().paused:
            Log.log("MENU HANDLER CANCEL!")
                
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
    
    if appearTween: appearTween.stop()
    if vanishTween: vanishTween.stop()
    if vanishMenu:  menuVanished()
    
    if activeMenu and activeMenu != menu:
        vanish(activeMenu, from, false)
    
    Post.menuSound.emit("appear")
        
    activeMenu = menu
    
    menu.appear()
        
    Post.menuAppear.emit(menu)
        
    appearTween = create_tween()
    appearTween.set_ease(MENU_EASE)
    appearTween.set_trans(MENU_TRANS)

    menu.anchor_top    = 0
    menu.anchor_left   = 0
    menu.anchor_bottom = 1
    menu.anchor_right  = 1

    match from: 
        "bottom":
            menu.anchor_top    = 1
            menu.anchor_bottom = 2
            appearTween.tween_property(menu, "anchor_top", 0, APPEAR_TIME)
            appearTween.parallel().tween_property(menu, "anchor_bottom", 1, APPEAR_TIME)

        "top":
            menu.anchor_top    = -1
            menu.anchor_bottom = 0
            appearTween.tween_property(menu, "anchor_top", 0, APPEAR_TIME)
            appearTween.parallel().tween_property(menu, "anchor_bottom", 1, APPEAR_TIME)

        "right":
            menu.anchor_left   = 1
            menu.anchor_right  = 2
            appearTween.tween_property(menu, "anchor_left", 0, APPEAR_TIME)
            appearTween.parallel().tween_property(menu, "anchor_right", 1, APPEAR_TIME)

        "left":
            menu.anchor_left   = -1
            menu.anchor_right  = 0
            appearTween.tween_property(menu, "anchor_left", 0, APPEAR_TIME)
            appearTween.parallel().tween_property(menu, "anchor_right", 1, APPEAR_TIME)
    
    appearTween.tween_callback(menuAppeared)
    return appearTween

func vanish(menu, from="bottom", sound=true):
    
    menu.release_focus()
    
    if menu == activeMenu:
        activeMenu = null
    
    vanishMenu = menu
    menu.vanish()
    
    Post.menuVanish.emit(menu)
    if sound: Post.menuSound.emit("vanish")

    vanishTween = create_tween()
    vanishTween.set_ease(MENU_EASE)
    vanishTween.set_trans(MENU_TRANS)
    
    menu.anchor_top    = 0
    menu.anchor_left   = 0
    menu.anchor_bottom = 1
    menu.anchor_right  = 1
    
    match from: 
    
        "bottom":
            vanishTween.tween_property(menu, "anchor_top", -1, VANISH_TIME)
            vanishTween.parallel().tween_property(menu, "anchor_bottom", 0, VANISH_TIME)

        "top":
            vanishTween.tween_property(menu, "anchor_top", 1, VANISH_TIME)
            vanishTween.parallel().tween_property(menu, "anchor_bottom", 2, VANISH_TIME)
            
        "right":
            vanishTween.tween_property(menu, "anchor_left", -1, VANISH_TIME)
            vanishTween.parallel().tween_property(menu, "anchor_right", 0, VANISH_TIME)            

        "left":
            vanishTween.tween_property(menu, "anchor_left", 1, VANISH_TIME)
            vanishTween.parallel().tween_property(menu, "anchor_right", 2, VANISH_TIME)            

    vanishTween.tween_callback(menuVanished)
    return vanishTween

func menuAppeared():
    
    if activeMenu:
        activeMenu.appeared()
    else:
        Log.log("NO ACTIVE MENU?")
    
func menuVanished():
    
    if vanishMenu:
        vanishMenu.vanished()
        vanishMenu.hide()
        vanishMenu = null
        if not activeMenu and get_tree().paused:
            Post.resumeGame.emit()
    else:
        Log.log("NO VANISH MENU?")

func slideInTop(menu:Control):

    menu.show()
    
    menu.anchor_top    = 0 - menu.size.y/1080.0
    menu.anchor_bottom = 1 - menu.size.y/1080.0
        
    var tween = create_tween()
    tween.set_ease(Tween.EASE_OUT)
    tween.set_trans(Tween.TRANS_QUINT)
    tween.tween_property(menu, "anchor_top", 0, SLIDE_IN_TIME)
    tween.parallel().tween_property(menu, "anchor_bottom", 1, SLIDE_IN_TIME)
    return tween
    
func slideOutTop(menu:Control):

    menu.anchor_top    = 0
    menu.anchor_bottom = 1

    var tween = create_tween()
    tween.tween_property(menu, "anchor_top", 0 - menu.size.y/1080.0, SLIDE_OUT_TIME)
    tween.parallel().tween_property(menu, "anchor_bottom", 1 - menu.size.y/1080.0, SLIDE_OUT_TIME)
    tween.tween_callback(menu.hide)
    return tween    

func slideInRight(menu:Control):

    menu.show()
    
    menu.anchor_left  = 0 + SLIDE_RIGHT
    menu.anchor_right = 1 + SLIDE_RIGHT
        
    var tween = create_tween()
    tween.set_ease(Tween.EASE_OUT)
    tween.set_trans(Tween.TRANS_QUINT)
    tween.tween_property(menu, "anchor_left", 0, SLIDE_IN_TIME)
    tween.parallel().tween_property(menu, "anchor_right", 1, SLIDE_IN_TIME)
    return tween
    
func slideOutRight(menu:Control):

    menu.anchor_left  = 0
    menu.anchor_right = 1
    
    var tween = create_tween()
    tween.tween_property(menu, "anchor_left", 0 + SLIDE_RIGHT, SLIDE_OUT_TIME)
    tween.parallel().tween_property(menu, "anchor_right", 1 + SLIDE_RIGHT, SLIDE_OUT_TIME)
    tween.tween_callback(menu.hide)
    return tween    
