class_name SettingsMenu 
extends Menu

func _ready():
    
    backFrom = "top"
    Post.subscribe(self)
    super._ready()

func appear():
    
    %Brightness.value   = %Camera.get_node("Light").light_energy
    %Hires.value        = get_window().content_scale_mode == Window.CONTENT_SCALE_MODE_CANVAS_ITEMS
    %TimeScale.value    = Engine.time_scale
    %EnemySpeed.value   = Info.enemySpeed
    %MasterVolume.value = AudioServer.get_bus_volume_linear(AudioServer.get_bus_index("Master"))
    %MusicVolume.value  = AudioServer.get_bus_volume_linear(AudioServer.get_bus_index("Music"))
    %GameVolume.value   = AudioServer.get_bus_volume_linear(AudioServer.get_bus_index("Game"))
    %MenuVolume.value   = AudioServer.get_bus_volume_linear(AudioServer.get_bus_index("Menu"))
    %Clock.value        = HUD.showClock
            
    onBrightness(%Brightness.value)
    onTimescale(%TimeScale.value)       
    onEnemySpeed(%EnemySpeed.value)
    #onMasterVolume(%MasterVolume.value)
    super.appear()
        
func appeared():
    
    %MasterVolume.slider.grab_focus()
    super.appeared()

func onButtonHover(button: Node): 
    
    button.grab_focus()

func onBrightness(value):
    
    %Camera.get_node("Light").light_energy = value
    
func onHires(value):
    
    if value:
        get_window().content_scale_mode = Window.CONTENT_SCALE_MODE_CANVAS_ITEMS
        %HiresValue.text = "%dx%d" % [get_window().size.x, get_window().size.y]
    else:
        get_window().content_scale_mode = Window.CONTENT_SCALE_MODE_VIEWPORT
        %HiresValue.text = "%dx%d" % [get_window().content_scale_size.x, get_window().content_scale_size.y]

func onTimescale(value):

    Engine.time_scale = value
    if Engine.time_scale > 1:
        Engine.physics_ticks_per_second = 120
    else:
        Engine.physics_ticks_per_second = 60
        
    Log.log("ticks per second", Engine.physics_ticks_per_second, "timescale", Engine.time_scale)

func onEnemySpeed(value):
    
    Info.setEnemySpeed(value)

func onMasterVolume(value):
    
    Post.statChanged.emit("masterVolume", value)
    Log.log("master", value, linear_to_db(value))
    AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Master"), linear_to_db(value))

func onMusicVolume(value):
    
    Post.statChanged.emit("musicVolume", value)
    Log.log("music", value, linear_to_db(value))
    if value:
        %MusicPlayer.play()
    else:
        %MusicPlayer.stop()
    AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Music"), linear_to_db(value))

func onGameVolume(value):
    
    Post.statChanged.emit("gameVolume", value)
    Log.log("game", value, linear_to_db(value))
    AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Game"), linear_to_db(value))

func onMenuVolume(value):
    
    Post.statChanged.emit("menuVolume", value)
    Log.log("menu", value, linear_to_db(value))
    AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Menu"), linear_to_db(value))
    
func onClock(value):
    
    HUD.showClock = %Clock.value
    
func onMouseLock(value):
    
    get_node("/root/World/MouseHandler").mouseLock = value

func onMouseHide(value):
    
    get_node("/root/World/MouseHandler").mouseHide = value
    
func on_save(data:Dictionary):

    data.Settings = {}
    data.Settings.timeScale    = Engine.time_scale
    data.Settings.enemySpeed   = Info.enemySpeed
    data.Settings.brightness   = %Camera.get_node("Light").light_energy
    data.Settings.hires        = get_window().content_scale_mode == Window.CONTENT_SCALE_MODE_CANVAS_ITEMS
    data.Settings.volumeMaster = AudioServer.get_bus_volume_linear(AudioServer.get_bus_index("Master"))
    data.Settings.volumeMusic  = AudioServer.get_bus_volume_linear(AudioServer.get_bus_index("Music"))
    data.Settings.volumeGame   = AudioServer.get_bus_volume_linear(AudioServer.get_bus_index("Game"))
    data.Settings.volumeMenu   = AudioServer.get_bus_volume_linear(AudioServer.get_bus_index("Menu"))
    data.Settings.clock        = HUD.showClock
    data.Settings.mouseLock    = get_node("/root/World/MouseHandler").mouseLock
    data.Settings.mouseHide    = get_node("/root/World/MouseHandler").mouseHide
    
func on_load(data:Dictionary):
    
    Log.log("settings")
    
    if not data.has("Settings"): return
    
    Log.log("settings", data.Settings)
    
    if data.Settings.has("timeScale"):    onTimescale(data.Settings.timeScale)
    if data.Settings.has("enemySpeed"):   onEnemySpeed(data.Settings.enemySpeed)
    if data.Settings.has("brightness"):   onBrightness(data.Settings.brightness)
    if data.Settings.has("hires"):        onHires(data.Settings.hires)
    if data.Settings.has("volumeMaster"): onMasterVolume(data.Settings.volumeMaster)
    if data.Settings.has("volumeMusic"):  onMusicVolume(data.Settings.volumeMusic)
    if data.Settings.has("volumeGame"):   onGameVolume(data.Settings.volumeGame)
    if data.Settings.has("volumeMenu"):   onMenuVolume(data.Settings.volumeMenu)
    if data.Settings.has("clock"):        onClock(data.Settings.clock)
    if data.Settings.has("mouseLock"):    onMouseLock(data.Settings.mouseLock)
    if data.Settings.has("mouseHide"):    onMouseHide(data.Settings.mouseHide)
