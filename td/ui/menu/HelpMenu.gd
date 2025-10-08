class_name HelpMenu
extends Menu

func appeared():
    
    %Back.grab_focus()
    super.appeared()

func back():
    
    backMenu = %MainMenu
    backFrom = "top"
    super.back()
