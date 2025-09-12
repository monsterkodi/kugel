class_name PauseMenu 
extends Menu

func _on_resume_pressed():   Post.resumeGame.emit()
func _on_restart_pressed():  Post.restartLevel.emit()
func _on_quit_pressed():     Post.quitGame.emit()
func _on_new_game_pressed(): Post.newGame.emit()
func _on_settings_pressed(): Post.settings.emit()
func _on_cards_pressed():    %PermViewer.pauseOnBack = true; %MenuHandler.appear(%PermViewer, "right")
func _on_cheat_pressed():    %MenuHandler.appear(%CheatMenu)

func appeared():
    
    Utils.childrenWithClass(self, "Button")[0].grab_focus()
    super.appeared()
