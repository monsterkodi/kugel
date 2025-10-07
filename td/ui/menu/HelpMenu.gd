class_name HelpMenu
extends Menu

func appeared():
    
    %Back.grab_focus()

func back():
    
    %MenuHandler.appear(%MainMenu)
