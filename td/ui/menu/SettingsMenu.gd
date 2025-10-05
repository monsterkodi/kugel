class_name SettingsMenu 
extends Menu

func _ready():
    
    backFrom = "top"
    Post.subscribe(self)
    
    for child in settingsChildren():
        child.valueChanged.connect(valueChanged.bind(child.name))
    
    super._ready()
    
func settingsChildren(): 
    
    return Utils.childrenWithClasses(self, ["SettingsSlider", "SettingsCheck"])
    
func valueChanged(value, key):
    
    Settings.applySetting(key, value)
    if key == "hires": updateHiresValue()

func appear():
    
    for child in settingsChildren():
        child.value = Settings.settings[child.name]

    updateHiresValue()
    super.appear()
        
func appeared():
    
    %volumeMaster.slider.grab_focus()
    super.appeared()

func onButtonHover(button: Node): 
    
    button.grab_focus()

func updateHiresValue():
    
    if get_window().content_scale_mode == Window.CONTENT_SCALE_MODE_CANVAS_ITEMS:
        %hiresValue.text = "%dx%d" % [get_window().size.x, get_window().size.y]
    else:
        %hiresValue.text = "%dx%d" % [get_window().content_scale_size.x, get_window().content_scale_size.y]

func onResize():

    updateHiresValue()
