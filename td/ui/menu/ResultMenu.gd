extends Menu

func appeared():
    
    %Buttons.get_child(0).grab_focus()
    
func onRetry():
    
    %MenuHandler.appear(%HandChooser)

func onMainMenu():
    
    %MenuHandler.appear(%MainMenu)
