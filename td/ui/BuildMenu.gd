extends Control

signal resumeGame
signal buildItem

const BUILD_BUTTON = preload("res://ui/BuildButton.tscn")

func _ready():
    
    addButton("Turret")
    
func addButton(id:String):
    
    var button = BUILD_BUTTON.instantiate()
    %Buttons.add_child(button)
    button.name = id
    button.pressed.connect(buttonPressed)
    #button.get_node("Button").connect("pressed", buttonPressed2, CONNECT_APPEND_SOURCE_OBJECT)

func buttonPressed(button):
    
    Log.log("button pressed", button)
    buildItem.emit(button)

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
