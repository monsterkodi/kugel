class_name BuildMenu
extends Menu

const BUILD_BUTTON = preload("res://ui/build/BuildButton.tscn")

func _ready():
    
    Post.subscribe(self)
    
func buildingPlaced(building):
    
    showButtons()
    
    var button = %Buttons.find_child(building.name, true, false)
    if button:
        button.get_child(0).grab_focus()
    else:
        focusFirstButton()
        
func addButton(building:String):
    
    var button:BuildButton = BUILD_BUTTON.instantiate()
    %Buttons.add_child(button)
    button.setBuilding(building)
    button.focused.connect(buttonFocused)

func buttonFocused(button):

    Post.buildingGhost.emit(button.name)
    
func showButtons():
    
    Utils.freeChildren(%Buttons)
    
    var buildings = Info.buildingNamesSortedByPrice()
    
    if Info.isAnyBuildingPlaced("Shield"):
        buildings = buildings.filter(func(b): return b != "Shield")
    
    for building in buildings:
        if Wallet.balance >= Info.priceForBuilding(building) or \
            %BattleCards.countBattleCards(building):
            addButton(building)

func appear():

    showButtons()
        
    if %Player.vehicle is RigidBody3D:
        %Player.vehicle.linear_velocity = Vector3.ZERO
     
    var trans:Transform3D = %Player.global_transform
    trans.origin.y = 0
    %Builder.appear(trans)
    %Camera/Follow.target = %Builder.vehicle
        
    super.appear()
    
func appeared():
    
    focusFirstButton()
    super.appeared()
    
func focusFirstButton():
    
    if %Buttons.get_child_count():
        %Buttons.get_child(0).get_child(0).grab_focus()

func back(): %MenuHandler.vanish(self, "right")

func vanish():
    
    %Camera/Follow.target = %Player
    %Builder.vanish()
    if %Player.vehicle is RigidBody3D:
        %Player.vehicle.linear_velocity = Vector3.ZERO
                
    super.vanish()
