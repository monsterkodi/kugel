extends Control

signal resumeGame
signal loadGame
signal saveGame
signal quitGame

func _on_quit_button_pressed():   quitGame.emit()
func _on_resume_button_pressed(): resumeGame.emit()
func _on_load_pressed():          loadGame.emit()
func _on_save_pressed():          saveGame.emit()

func _input(event: InputEvent):
    
    if not visible: return
    if Input.is_action_just_pressed("ui_cancel"): # to enable joypad B
        get_viewport().set_input_as_handled()
        resumeGame.emit()

func _on_visibility_changed():
    if is_visible_in_tree():
        %Resume.grab_focus()

func onButtonHover(button: Node): 
    button.grab_focus()
