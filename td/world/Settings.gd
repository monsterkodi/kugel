class_name Settings
extends Node

static var defaults = {
    "timeScale":    1.0,
    "enemySpeed":   1.0,
    "brightness":   1.0,
    "hires":        false,
    "volumeMaster": 1.0,
    "volumeMusic":  0.5,
    "volumeGame":   1.0,
    "volumeMenu":   1.0,
    "clock":        false,
    "fullscreen":   false,
    "mouseLock":    false,
    "mouseHide":    false,
}

static var settings = {}
        
static func applySetting(key, value):
    
    settings[key] = value
    
    match key:
        
        "timeScale":    setTimeScale(value)
        "enemySpeed":   Info.setEnemySpeed(value)
        "brightness":   node("Camera/Light").light_energy = value
        "hires":        setHires(value)
        "volumeMaster": AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Master"), linear_to_db(value))
        "volumeGame":   AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Game"),   linear_to_db(value))
        "volumeMenu":   AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Menu"),   linear_to_db(value))
        "volumeMusic":  
                        AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Music"),       linear_to_db(value))
                        AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Menu Music"),  linear_to_db(value))
        "clock":        HudClock.showClock = value
        "fullscreen":   setFullscreen(value)
        "mouseLock":    node("MouseHandler").mouseLock = value
        "mouseHide":    node("MouseHandler").mouseHide = value
    
static func setTimeScale(value):
    
    Engine.time_scale = value
    if Engine.time_scale > 1:
        Engine.physics_ticks_per_second = 120
    else:
        Engine.physics_ticks_per_second = 60
        
    #Log.log("ticks per second", Engine.physics_ticks_per_second, "timescale", Engine.time_scale)    

static func setHires(value):

    if value:
        world().get_window().content_scale_mode = Window.CONTENT_SCALE_MODE_CANVAS_ITEMS
    else:
        world().get_window().content_scale_mode = Window.CONTENT_SCALE_MODE_VIEWPORT
        
static func setFullscreen(value):
    
    if value:
        DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
    else:
        DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
        DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_BORDERLESS, false)
        DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_RESIZE_DISABLED, false)
        
static func load(data):
    
    if data.has("Settings"): 
        #Log.log("apply saved data")
        apply(data.Settings)

static func save(data):
    
    data.Settings = settings
        
static func apply(dict):
    
    Log.log("dict", dict)
    for key in dict:
        applySetting(key, dict[key])
        
static func world():
    
    return Engine.get_main_loop().root.get_node("World")
        
static func node(path): 
    
    return world().get_node(path)
        
