extends Node

func _ready():
    
    %Saver.load()

func _unhandled_input(_event: InputEvent) -> void:
    
    if Input.is_action_just_pressed("ui_cancel"):
        %Saver.save()
        get_tree().quit()
        
    if Input.is_action_just_pressed("save"): %Saver.save()
    if Input.is_action_just_pressed("load"): %Saver.load()
    
    if Input.is_key_pressed(KEY_META):
        if Input.is_key_pressed(KEY_S): %Saver.save()
        if Input.is_key_pressed(KEY_R): %Saver.load()
