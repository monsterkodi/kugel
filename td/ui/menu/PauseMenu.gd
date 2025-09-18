class_name PauseMenu 
extends Menu

func _on_resume_pressed():    Post.resumeGame.emit()
func _on_restart_pressed():   Post.restartLevel.emit()
func _on_main_menu_pressed(): Post.mainMenu.emit()
func _on_settings_pressed():  Post.settings.emit(self)
func _on_cards_pressed():     %PermViewer.pauseOnBack = true; %MenuHandler.appear(%PermViewer, "right")
func _on_cheat_pressed():     %MenuHandler.appear(%CheatMenu)

func _ready():
    
    %Buttons.get_child(0).focus_neighbor_top     = %Buttons.get_child(-1).get_path()
    %Buttons.get_child(-1).focus_neighbor_bottom = %Buttons.get_child(0).get_path()

func appeared():
    
    Utils.childrenWithClass(self, "Button")[0].grab_focus()
    super.appeared()
