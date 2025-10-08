class_name CreditsMenu
extends Menu

func back():
    
    backMenu = %MainMenu
    backFrom = "top"
    super.back()

func _input(event: InputEvent):
    
    if event is InputEventJoypadButton or event is InputEventKey or event is InputEventMouseButton:
        back()
