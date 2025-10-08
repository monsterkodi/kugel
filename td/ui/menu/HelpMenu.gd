class_name HelpMenu
extends Menu

func appeared():
    
    %Back.grab_focus()
    super.appeared()

func back():
    
    if is_processing_input():
        backFrom = "top"
        super.back()
