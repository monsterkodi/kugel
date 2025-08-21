extends Control

signal resumeGame
signal quitGame

func _on_quit_button_pressed():   quitGame.emit()
func _on_resume_button_pressed(): resumeGame.emit()

func _on_visibility_changed():
    if is_visible_in_tree():
        %Resume.grab_focus()

func onButtonHover(button: Node):
    button.grab_focus()
