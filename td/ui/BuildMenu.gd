extends Control

const BUILD_BUTTON = preload("res://ui/BuildButton.tscn")

func _ready():
    
    Post.buildingPlaced.connect(buildingPlaced)
    
func buildingPlaced(building):
    
    showMenu()
    var button = %Buttons.find_child(building, true, false)
    if button:
        button.get_child(0).grab_focus()
        
func addButton(building:String):
    
    var button:BuildButton = BUILD_BUTTON.instantiate()
    %Buttons.add_child(button)
    button.setBuilding(building)
    button.pressed.connect(buttonPressed)
    button.focused.connect(buttonFocused)

func buttonPressed(button):
    pass
    
func buttonFocused(button):

    Post.builderGhost.emit(button.name)
    
func showButtons():
    
    while %Buttons.get_child_count():
        %Buttons.get_child(0).free()
    
    var buildings = Info.buildingNamesSortedByPrice()
    
    if Info.isAnyBuildingPlaced("Shield"):
        buildings = buildings.filter(func(b): return b != "Shield")
    
    for building in buildings:
        if Wallet.balance >= Info.priceForBuilding(building):    
            addButton(building)

func showMenu():

    showButtons()
        
    if %Buttons.get_child_count():
        %Buttons.get_child(0).get_child(0).grab_focus()
    else:
        Post.builderGhost.emit("")
        
    visible = true
    
func hideMenu():
    
    visible = false
    get_viewport().gui_release_focus()
    
