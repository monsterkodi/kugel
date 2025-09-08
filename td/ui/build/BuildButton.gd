class_name BuildButton extends Control

signal pressed
signal focused

func buttonPressed(): pressed.emit(self)
func buttonFocused(): focused.emit(self)

func setBuilding(building:String):
    
    name = building
    %Viewport.setBuilding(building)
