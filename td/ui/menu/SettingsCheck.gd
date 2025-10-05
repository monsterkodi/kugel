class_name SettingsCheck
extends CheckButton

signal valueChanged

const activeColor  = Color(1, 0, 0)
const passiveColor = Color(0.4, 0.4, 0.4)

var value : bool = false :
    set(v): button_pressed = v
    get():  return button_pressed

func _ready():
    
    custom_minimum_size.x = 360.0
    custom_minimum_size.y = 70.0
    size_flags_horizontal = Control.SIZE_SHRINK_BEGIN
    size_flags_vertical   = Control.SIZE_SHRINK_CENTER
    passiveColors()
    connect("mouse_entered", onHover)
    connect("focus_entered", onHover)
    connect("focus_exited",  onLeave)
    connect("toggled",       onToggle)
    
func onToggle(v):
    
    valueChanged.emit(v)
    if v:
        Post.menuSound.emit("check")
    else:
        Post.menuSound.emit("uncheck")
    
func onHover():
    
    grab_focus()
    activeColors()
    
func activeColors():
    
    add_theme_color_override("font_pressed_color", activeColor)
    add_theme_color_override("font_hover_pressed_color", activeColor)
    add_theme_color_override("font_normal_color", activeColor)
    add_theme_color_override("font_focus_color", activeColor)
    add_theme_color_override("font_hover_color", activeColor)
    add_theme_color_override("font_color", activeColor)
    add_theme_color_override("font_hover_pressed", activeColor)

func onLeave():
    
    passiveColors()

func passiveColors():
    
    add_theme_color_override("font_pressed_color", passiveColor)
    add_theme_color_override("font_hover_pressed_color", passiveColor)
    add_theme_color_override("font_normal_color", passiveColor)
    add_theme_color_override("font_focus_color", passiveColor)
    add_theme_color_override("font_hover_color", passiveColor)
    add_theme_color_override("font_color", passiveColor)
    add_theme_color_override("font_hover_pressed", passiveColor)
