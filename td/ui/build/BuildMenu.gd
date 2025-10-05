class_name BuildMenu
extends Menu

const BUILD_BUTTON = preload("res://ui/build/BuildButton.tscn")

@onready var balance: Label = %Balance
@onready var minus:   Label = %Minus
@onready var cost:    Label = %Cost
@onready var plus:    Label = %Plus
@onready var gain:    Label = %Gain

func _ready():
    
    Post.subscribe(self)
    
func statChanged(statName, value):

    match statName:
        
        "balance":            
            
            balance.text = str(value)
    
func buildingSold():
    
    showButtons()
    #%Buttons.get_child(-1).grab_focus()
        
func buildingPlaced(building):
    
    showButtons()
    
    var button = %Buttons.find_child(building.name, true, false)
    if button:
        button.grab_focus()
    else:
        focusFirstButton()
        
func addButton(building:String):
    
    var button:BuildButton = BUILD_BUTTON.instantiate()
    %Buttons.add_child(button)
    button.setBuilding(building)
    button.focus_entered.connect(buttonFocused.bind(button))

func buttonFocused(button):

    #Log.log("Post.buildingGhost", button.name)
    Post.buildingGhost.emit(button.name)
    
    updateBalance()
    
func focusedButton():
    
    for button in %Buttons.get_children():
        if button.has_focus(): return button
    return null
    
func buildingSlotChanged(slot):
    
    updateBalance()
    
func updateBalance():
    
    var button = focusedButton()
    if not button: return
    
    var builder = %Builder
    if builder.targetSlot and builder.targetSlot is Slot and builder.targetSlot.get_child_count():
        var building = %Builder.targetSlot.get_child(0)
        if building.name == button.name:
            gain.text  = ""
            plus.text  = ""
            cost.text  = ""
            minus.text = ""
            return
        gain.text  = str(Info.priceForBuilding(building.name))
        plus.text  = "+"
    else:
        gain.text  = ""
        plus.text  = ""
    
    if button.name == "Sell":
        cost.text  = ""
        minus.text = ""
    else:
        minus.text = "-"
        if %BattleCards.countCards(button.name):
            cost.text = "card"
        else:
            cost.text = str(Info.priceForBuilding(button.name))
    
func showButtons():
    
    Utils.freeChildren(%Buttons)
    
    var buildings = Info.buildingNamesSortedByPrice()
    
    if Info.isAnyBuildingPlaced("Shield"):
        buildings = buildings.filter(func(b): return b != "Shield")
        
    for building in buildings:
        if Wallet.balance >= Info.priceForBuilding(building) and \
            Info.isUnlockedBuilding(building) or \
            %BattleCards.countCards(building):
                addButton(building)
    
    Utils.wrapFocusVertical(%Buttons)            

func appear():

    showButtons()
        
    if %Player.vehicle is RigidBody3D:
        %Player.vehicle.linear_velocity = Vector3.ZERO
     
    var trans:Transform3D = %Player.global_transform
    trans.origin.y = 0
    %Builder.appear(trans)
    %Camera/FollowCam.target = %Builder.vehicle
        
    super.appear()
    
func appeared():
    
    focusFirstButton()
    super.appeared()
    
func focusFirstButton():
    
    if %Buttons.get_child_count():
        %Buttons.get_child(0).grab_focus()

func back(): %MenuHandler.vanish(self, "right")

func vanish():
    
    %Camera/FollowCam.target = %Player
    %Builder.vanish()
    if %Player.vehicle is RigidBody3D:
        %Player.vehicle.linear_velocity = Vector3.ZERO
                
    super.vanish()
