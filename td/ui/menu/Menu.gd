class_name Menu
extends PanelContainer

var backMenu:Menu
var backFrom = "bottom"

func _ready():
    
    #Log.log("new Menu", self)
    set_process_input(false)
    
func back():
      
    if backMenu:
        %MenuHandler.appear(backMenu, backFrom)
        backMenu = null
    else:
        %MenuHandler.vanish(self)
        
func vanish():   pass
func appear():   show()
func appeared(): set_process_input(true)
func vanished(): set_process_input(false)

func _input(event: InputEvent):
    
    if visible:
        if event.is_action_pressed("ui_cancel"):
            #Log.log("Menu.cancel", self)
            get_viewport().set_input_as_handled()
            accept_event()
            back()
