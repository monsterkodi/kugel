extends Control

signal resumeGame
signal buildItem

const BUILD_BUTTON = preload("res://ui/BuildButton.tscn")

func _ready():
    
    pass
        
func addButton(building:String):
    
    var button:BuildButton = BUILD_BUTTON.instantiate()
    %Buttons.add_child(button)
    button.setBuilding(building)
    button.pressed.connect(buttonPressed)
    button.focused.connect(buttonFocused)

func buttonPressed(button):
    pass
    
func buttonFocused(button):

    buildItem.emit(button)

func showMenu():

    while %Buttons.get_child_count():
        %Buttons.remove_child(%Buttons.get_child(0))
    
    for building in ["Pole", "Turret", "Bouncer", "Laser", "Shield"]:
        if Wallet.balance >= Wallet.priceForBuilding(building):    
            addButton(building)
    
    if %Buttons.get_child_count():
        %Buttons.get_child(0).get_child(0).grab_focus()
        
    visible = true
    
func hideMenu():
    
    visible = false
    get_viewport().gui_release_focus()
    
func _input(event: InputEvent):
    
    if not visible: return
    
    if Input.is_action_just_pressed("ui_cancel"): # to enable joypad B
        get_viewport().set_input_as_handled()
        resumeGame.emit()
