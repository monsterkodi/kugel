@tool
class_name SettingsSlider
extends HBoxContainer

var label : Label
var slider : HSlider
var valueLabel : Label

const activeColor = Color(1, 0, 0)

signal valueChanged

@export var text:String = "Slider" :
    set(v): 
        text = v  
        if label: label.text = text

@export var value: float = 0.0 :
    set(v): 

        if v > value:
            Post.menuSound.emit("slider")
        elif v < value:
            Post.menuSound.emit("slider_down")
            
        value = v
        if slider: slider.value = v
        if valueLabel: 
            if valueStep != 1.0:
                valueLabel.text = Utils.trimFloat(v, 1)
            else:
                valueLabel.text = str(int(v))
        
@export var valueMin: float = 0.0 :
    set(v): 
        valueMin = v
        if slider: slider.min_value = v

@export var valueMax: float = 10.0 :
    set(v): 
        valueMax = v
        if slider: slider.max_value = v

@export var valueStep: float = 1.0 :
    set(v): 
        valueStep = v
        if slider: slider.step = v
        
func _ready():
    
    custom_minimum_size.x = 460
    custom_minimum_size.y = 20
    size_flags_vertical = Control.SIZE_SHRINK_CENTER
    
    mouse_entered.connect(setFocus)
    
    label = Label.new()
    label.custom_minimum_size.x = 300
    label.size_flags_vertical = Control.SIZE_SHRINK_CENTER
    #label.mouse_entered.connect(setFocus)
    add_child(label)

    slider = HSlider.new()
    slider.custom_minimum_size.x = 300
    slider.size_flags_vertical = Control.SIZE_SHRINK_CENTER
    slider.value_changed.connect(onValueChanged)
    slider.focus_exited.connect(unsetFocus)
    slider.focus_entered.connect(setFocus)
    
    add_child(slider)

    valueLabel = Label.new()
    valueLabel.custom_minimum_size.x = 100
    valueLabel.size_flags_vertical = Control.SIZE_SHRINK_CENTER
    add_child(valueLabel)
    
    text      = text
    valueMin  = valueMin
    valueMax  = valueMax
    valueStep = valueStep
    value     = value
    
func setFocus():
    
    label.add_theme_color_override("font_color", activeColor)
    slider.grab_focus()
    
func unsetFocus():

    label.remove_theme_color_override("font_color")
    
func onValueChanged(v):
    
    value = v
    valueChanged.emit(v)
