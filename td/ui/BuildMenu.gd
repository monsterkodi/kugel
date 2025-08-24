extends Control

signal resumeGame

const BUILD_BUTTON = preload("res://ui/BuildButton.tscn")

func _ready():
    
    var button1 = BUILD_BUTTON.instantiate()
    %Buttons.add_child(button1)
    var button2 = BUILD_BUTTON.instantiate()
    %Buttons.add_child(button2)

func showMenu():
    
    visible = true
    %Buttons.get_child(0).get_child(0).grab_focus()
    
func hideMenu():
    
    visible = false
    get_viewport().gui_release_focus()
    
func _input(event: InputEvent):
    
    if not visible: return
    
    if Input.is_action_just_pressed("ui_cancel"): # to enable joypad B
        get_viewport().set_input_as_handled()
        resumeGame.emit()
