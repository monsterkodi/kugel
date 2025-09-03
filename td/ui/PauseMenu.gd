class_name PauseMenu extends Control

signal settings
signal loadGame
signal saveGame
signal quitGame
signal resumeGame
signal restartGame

func _on_resume_pressed():   resumeGame.emit()
func _on_restart_pressed():  restartGame.emit()
func _on_settings_pressed(): settings.emit()
func _on_load_pressed():     loadGame.emit()
func _on_save_pressed():     saveGame.emit()
func _on_quit_pressed():     quitGame.emit()

func _on_visibility_changed():
    
    if is_visible_in_tree() and %Resume.is_inside_tree():
        %Resume.grab_focus()

func onButtonHover(button: Node):
    
    button.grab_focus()
