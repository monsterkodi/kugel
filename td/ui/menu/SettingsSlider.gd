@tool
class_name SettingsSlider
extends HBoxContainer

var label : Label
var slider : HSlider
var valueLabel : Label

signal valueChanged

@export var text:String = "Slider" :
    set(v): 
        text = v  
        if label: label.text = text

@export var value: float = 0.0 :
    set(v): 
        value = v
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
    custom_minimum_size.y = 60
    
    label = Label.new()
    label.custom_minimum_size.x = 300
    label.size_flags_vertical = Control.SIZE_SHRINK_CENTER
    add_child(label)

    slider = HSlider.new()
    slider.custom_minimum_size.x = 300
    slider.size_flags_vertical = Control.SIZE_SHRINK_CENTER
    slider.value_changed.connect(onValueChanged)
    
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
    
func onValueChanged(v):
    
    value = v
    valueChanged.emit(v)
