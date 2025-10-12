class_name Menu
extends PanelContainer

var backMenu:Menu
var backFrom = "bottom"

func _ready():
    
    set_process_input(false)
    
func back():
    
    set_process_input(false)  
    if backMenu:
        %MenuHandler.call_deferred("appear", backMenu, backFrom)
        backMenu = null
    else:
        %MenuHandler.vanish(self)
        
func vanish():   set_process_input(false)
func appear():   show()
func appeared(): set_process_input(true)
func vanished(): set_process_input(false)

func _input(event: InputEvent):
    
    if visible:
        if event.is_action_pressed("ui_cancel"):
            #Log.log("Menu._input cancel", self, event, event.as_text())
            get_viewport().set_input_as_handled()
            #accept_event()
            back()
