class_name PauseMenu 
extends Menu

func _on_resume_pressed():    if is_processing_input(): Post.resumeGame.emit()
func _on_main_menu_pressed(): if is_processing_input(): Post.mainMenu.emit()
func _on_settings_pressed():  if is_processing_input(): Post.settings.emit(self)
func _on_help_pressed():      if is_processing_input(): %HelpMenu.backMenu = self; %MenuHandler.appear(%HelpMenu)
func _on_cards_pressed():     if is_processing_input(): %PermViewer.pauseOnBack = true; %MenuHandler.appear(%PermViewer, "right")
func _on_cheat_pressed():     if is_processing_input(): %MenuHandler.appear(%CheatMenu)

func _ready():
    
    Utils.wrapFocusVertical(%Buttons)
    
func appear():
    
    %Cheat.visible = Settings.settings.cheatsEnabled
    
    super.appear()

func appeared():
    
    Utils.childrenWithClass(self, "Button")[0].grab_focus()
    super.appeared()
